import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/customer_review_model.dart';
import '../../services/supabase_service.dart';

class ReviewRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<CustomerReview>> fetchAllReviews() async {
    try {
      final response = await _client
          .from('customer_reviews')
          .select()
          .order('created_at', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => CustomerReview.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  Future<List<CustomerReview>> fetchActiveReviews() async {
    try {
      final response = await _client
          .from('customer_reviews')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => CustomerReview.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching active reviews: $e');
      return [];
    }
  }

  Future<void> addReview(CustomerReview review) async {
    try {
      await _client.from('customer_reviews').insert(review.toJson());
    } catch (e) {
      print('Error adding review: $e');
      throw Exception('Failed to add review');
    }
  }

  Future<void> updateReview(CustomerReview review) async {
    try {
      await _client
          .from('customer_reviews')
          .update(review.toJson())
          .eq('id', review.id);
    } catch (e) {
      print('Error updating review: $e');
      throw Exception('Failed to update review');
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      await _client.from('customer_reviews').delete().eq('id', id);
    } catch (e) {
      print('Error deleting review: $e');
      throw Exception('Failed to delete review');
    }
  }
}
