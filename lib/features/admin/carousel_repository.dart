import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/carousel_image_model.dart';
import '../../services/supabase_service.dart';

class CarouselRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<CarouselImage>> fetchAllCarouselImages() async {
    try {
      final response = await _client
          .from('carousel_images')
          .select()
          .order('display_order');

      if (response == null) return [];
      return (response as List)
          .map((json) => CarouselImage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching carousel images: $e');
      return [];
    }
  }

  Future<List<CarouselImage>> fetchActiveCarouselImages() async {
    try {
      final response = await _client
          .from('carousel_images')
          .select()
          .eq('is_active', true)
          .order('display_order');

      if (response == null) return [];
      return (response as List)
          .map((json) => CarouselImage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching active carousel images: $e');
      return [];
    }
  }

  Future<void> addCarouselImage(CarouselImage image) async {
    try {
      await _client.from('carousel_images').insert(image.toJson());
    } catch (e) {
      print('Error adding carousel image: $e');
      throw Exception('Failed to add carousel image');
    }
  }

  Future<void> updateCarouselImage(CarouselImage image) async {
    try {
      await _client
          .from('carousel_images')
          .update(image.toJson())
          .eq('id', image.id);
    } catch (e) {
      print('Error updating carousel image: $e');
      throw Exception('Failed to update carousel image');
    }
  }

  Future<void> deleteCarouselImage(String id) async {
    try {
      await _client.from('carousel_images').delete().eq('id', id);
    } catch (e) {
      print('Error deleting carousel image: $e');
      throw Exception('Failed to delete carousel image');
    }
  }
}
