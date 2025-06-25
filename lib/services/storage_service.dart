import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final SupabaseClient _client = SupabaseService().client;

  // Upload image to carousel-images bucket
  Future<String> uploadCarouselImage(
    Uint8List imageData,
    String fileName,
  ) async {
    try {
      final path = 'carousel/$fileName';
      await _client.storage.from('images').uploadBinary(path, imageData);

      final publicUrl = _client.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload carousel image: $e');
    }
  }

  // Upload image to review-images bucket
  Future<String> uploadReviewImage(Uint8List imageData, String fileName) async {
    try {
      final path = 'reviews/$fileName';
      await _client.storage.from('images').uploadBinary(path, imageData);

      final publicUrl = _client.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload review image: $e');
    }
  }

  // Upload product image
  Future<String> uploadProductImage(
    Uint8List imageData,
    String fileName,
  ) async {
    try {
      final path = 'products/$fileName';
      await _client.storage.from('images').uploadBinary(path, imageData);

      final publicUrl = _client.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload product image: $e');
    }
  }

  // Delete image from storage
  Future<void> deleteImage(String url) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('images');
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final path = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from('images').remove([path]);
      }
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw error for deletion failures
    }
  }
}
