import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/offer_model.dart';
import '../../services/supabase_service.dart';

class OfferRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<Offer>> fetchAllOffers() async {
    try {
      final response = await _client
          .from('offers')
          .select()
          .order('created_at', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => Offer.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching offers: $e');
      return [];
    }
  }

  Future<List<Offer>> fetchActiveOffers() async {
    try {
      final response = await _client
          .from('offers')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response == null) return [];
      return (response as List)
          .map((json) => Offer.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching active offers: $e');
      return [];
    }
  }

  Future<void> addOffer(Offer offer) async {
    try {
      await _client.from('offers').insert(offer.toJson());
    } catch (e) {
      print('Error adding offer: $e');
      throw Exception('Failed to add offer');
    }
  }

  Future<void> updateOffer(Offer offer) async {
    try {
      await _client.from('offers').update(offer.toJson()).eq('id', offer.id);
    } catch (e) {
      print('Error updating offer: $e');
      throw Exception('Failed to update offer');
    }
  }

  Future<void> deleteOffer(String id) async {
    try {
      await _client.from('offers').delete().eq('id', id);
    } catch (e) {
      print('Error deleting offer: $e');
      throw Exception('Failed to delete offer');
    }
  }
}
