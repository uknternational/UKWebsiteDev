import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';
import '../../services/supabase_service.dart';

class ProductRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<Product>> fetchAllProducts() async {
    try {
      final response = await _client.from('products').select();
      if (response == null) return [];
      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%',
          );

      if (response == null) return [];
      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('category', category);

      if (response == null) return [];
      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await _client.from('products').insert({
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'mrp': product.mrp,
        'offer': product.offer,
        'price_after_offer': product.priceAfterOffer,
        'price': product.price,
        'image_url': product.imageUrl,
        'category': product.category,
        'stock': product.stock,
        'is_top_selling': product.isTopSelling,
        'created_at': product.createdAt.toIso8601String(),
        'updated_at': product.updatedAt.toIso8601String(),
      }).select();

      print('Product added successfully: $response');
    } catch (e) {
      print('Error adding product: $e');
      if (e.toString().contains('does not exist')) {
        throw Exception(
          'Please create the products table in Supabase first. Go to Table Editor and create a new table named "products" with the required columns.',
        );
      }
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .update({
            'name': product.name,
            'description': product.description,
            'mrp': product.mrp,
            'offer': product.offer,
            'price_after_offer': product.priceAfterOffer,
            'price': product.price,
            'image_url': product.imageUrl,
            'category': product.category,
            'stock': product.stock,
            'is_top_selling': product.isTopSelling,
            'updated_at': product.updatedAt.toIso8601String(),
          })
          .eq('id', product.id)
          .select();

      print('Product updated successfully: $response');
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .delete()
          .eq('id', id)
          .select();

      print('Product deleted successfully: $response');
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
}
