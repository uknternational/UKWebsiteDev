import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class WishlistService {
  static final SupabaseClient _client = SupabaseService().client;

  // Check if user is authenticated
  static bool get _isAuthenticated => AuthService().isLoggedIn;
  static String? get _currentUserId => AuthService().currentUser?.id;

  static Future<List<Product>> getWishlistItems() async {
    try {
      if (!_isAuthenticated) return [];

      final response = await _client
          .from('wishlist_items')
          .select('*, products(*)')
          .eq('user_id', _currentUserId!);

      if (response == null) return [];

      return (response as List).map((item) {
        final productData = item['products'] as Map<String, dynamic>;
        return Product.fromJson(productData);
      }).toList();
    } catch (e) {
      print('Error loading wishlist items: $e');
      return [];
    }
  }

  static Future<void> addToWishlist(Product product) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('User must be logged in to add to wishlist');
      }

      // Check if item already exists in wishlist
      final existing = await _client
          .from('wishlist_items')
          .select()
          .eq('user_id', _currentUserId!)
          .eq('product_id', product.id);

      if (existing != null && (existing as List).isNotEmpty) {
        throw Exception('Product already in wishlist');
      }

      // Add to wishlist
      await _client.from('wishlist_items').insert({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': _currentUserId!,
        'product_id': product.id,
        'added_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding to wishlist: $e');
      throw Exception('Failed to add item to wishlist');
    }
  }

  static Future<void> removeFromWishlist(String productId) async {
    try {
      if (!_isAuthenticated) return;

      await _client
          .from('wishlist_items')
          .delete()
          .eq('user_id', _currentUserId!)
          .eq('product_id', productId);
    } catch (e) {
      print('Error removing from wishlist: $e');
      throw Exception('Failed to remove item from wishlist');
    }
  }

  static Future<bool> isInWishlist(String productId) async {
    try {
      if (!_isAuthenticated) return false;

      final response = await _client
          .from('wishlist_items')
          .select()
          .eq('user_id', _currentUserId!)
          .eq('product_id', productId);

      return response != null && (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking wishlist: $e');
      return false;
    }
  }

  static Future<void> clearWishlist() async {
    try {
      if (!_isAuthenticated) return;

      await _client
          .from('wishlist_items')
          .delete()
          .eq('user_id', _currentUserId!);
    } catch (e) {
      print('Error clearing wishlist: $e');
    }
  }

  static Future<int> getWishlistItemCount() async {
    final wishlistItems = await getWishlistItems();
    return wishlistItems.length;
  }
}
