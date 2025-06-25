import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

class CartService {
  static const String _cartKey = 'cart_items';
  static final SupabaseClient _client = SupabaseService().client;

  // Check if user is authenticated
  static bool get _isAuthenticated => AuthService().isLoggedIn;
  static String? get _currentUserId => AuthService().currentUser?.id;

  static Future<List<CartItem>> getCartItems() async {
    try {
      if (_isAuthenticated) {
        // Get cart items from database for authenticated users
        return await _getCartItemsFromDatabase();
      } else {
        // Get cart items from local storage for guest users
        return await _getCartItemsFromLocalStorage();
      }
    } catch (e) {
      print('Error loading cart items: $e');
      return [];
    }
  }

  static Future<List<CartItem>> _getCartItemsFromDatabase() async {
    try {
      final response = await _client
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', _currentUserId!);

      if (response == null) return [];

      return (response as List).map((item) {
        final productData = item['products'] as Map<String, dynamic>;
        final product = Product.fromJson(productData);

        return CartItem(
          id: item['id'] as String,
          product: product,
          quantity: item['quantity'] as int,
          addedAt: DateTime.parse(item['added_at'] as String),
        );
      }).toList();
    } catch (e) {
      print('Error loading cart from database: $e');
      return [];
    }
  }

  static Future<List<CartItem>> _getCartItemsFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        return cartList
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error loading cart from local storage: $e');
      return [];
    }
  }

  static Future<void> saveCartItems(List<CartItem> items) async {
    try {
      if (_isAuthenticated) {
        await _saveCartItemsToDatabase(items);
      } else {
        await _saveCartItemsToLocalStorage(items);
      }
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  static Future<void> _saveCartItemsToDatabase(List<CartItem> items) async {
    try {
      // Clear existing cart items for this user
      await _client.from('cart_items').delete().eq('user_id', _currentUserId!);

      // Insert new cart items
      if (items.isNotEmpty) {
        final cartData = items
            .map(
              (item) => {
                'id': item.id,
                'user_id': _currentUserId!,
                'product_id': item.product.id,
                'quantity': item.quantity,
                'added_at': item.addedAt.toIso8601String(),
              },
            )
            .toList();

        await _client.from('cart_items').insert(cartData);
      }
    } catch (e) {
      print('Error saving cart to database: $e');
      throw Exception('Failed to save cart to database');
    }
  }

  static Future<void> _saveCartItemsToLocalStorage(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart to local storage: $e');
    }
  }

  static Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      final cartItems = await getCartItems();

      // Check if item already exists in cart
      final existingIndex = cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex != -1) {
        // Update quantity
        final existingItem = cartItems[existingIndex];
        cartItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Add new item
        final cartItem = CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
          addedAt: DateTime.now(),
        );
        cartItems.add(cartItem);
      }

      await saveCartItems(cartItems);
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('Failed to add item to cart');
    }
  }

  static Future<void> removeFromCart(String cartItemId) async {
    try {
      if (_isAuthenticated) {
        await _client
            .from('cart_items')
            .delete()
            .eq('id', cartItemId)
            .eq('user_id', _currentUserId!);
      } else {
        final cartItems = await getCartItems();
        cartItems.removeWhere((item) => item.id == cartItemId);
        await saveCartItems(cartItems);
      }
    } catch (e) {
      print('Error removing from cart: $e');
      throw Exception('Failed to remove item from cart');
    }
  }

  static Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      if (_isAuthenticated) {
        if (quantity <= 0) {
          await removeFromCart(cartItemId);
        } else {
          await _client
              .from('cart_items')
              .update({'quantity': quantity})
              .eq('id', cartItemId)
              .eq('user_id', _currentUserId!);
        }
      } else {
        final cartItems = await getCartItems();
        final index = cartItems.indexWhere((item) => item.id == cartItemId);

        if (index != -1) {
          if (quantity <= 0) {
            cartItems.removeAt(index);
          } else {
            cartItems[index] = cartItems[index].copyWith(quantity: quantity);
          }
          await saveCartItems(cartItems);
        }
      }
    } catch (e) {
      print('Error updating quantity: $e');
      throw Exception('Failed to update quantity');
    }
  }

  static Future<void> clearCart() async {
    try {
      if (_isAuthenticated) {
        await _client
            .from('cart_items')
            .delete()
            .eq('user_id', _currentUserId!);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cartKey);
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  static Future<double> getCartTotal() async {
    final cartItems = await getCartItems();
    return cartItems.fold<double>(
      0.0,
      (total, item) => total + item.totalPrice,
    );
  }

  static Future<int> getCartItemCount() async {
    final cartItems = await getCartItems();
    return cartItems.fold<int>(0, (total, item) => total + item.quantity);
  }

  // Migrate local cart to database when user logs in
  static Future<void> migratLocalCartToDatabase() async {
    try {
      if (!_isAuthenticated) return;

      // Get items from local storage
      final localItems = await _getCartItemsFromLocalStorage();
      if (localItems.isEmpty) return;

      // Get current database items
      final dbItems = await _getCartItemsFromDatabase();

      // Merge items (combine quantities for same products)
      final Map<String, CartItem> mergedItems = {};

      // Add database items first
      for (final item in dbItems) {
        mergedItems[item.product.id] = item;
      }

      // Add/merge local items
      for (final localItem in localItems) {
        if (mergedItems.containsKey(localItem.product.id)) {
          final existing = mergedItems[localItem.product.id]!;
          mergedItems[localItem.product.id] = existing.copyWith(
            quantity: existing.quantity + localItem.quantity,
          );
        } else {
          mergedItems[localItem.product.id] = localItem;
        }
      }

      // Save merged items to database
      await _saveCartItemsToDatabase(mergedItems.values.toList());

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      print('Error migrating cart: $e');
    }
  }
}
