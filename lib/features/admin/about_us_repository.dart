import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/about_us_model.dart';
import '../../services/supabase_service.dart';

class AboutUsRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<AboutUsContent>> fetchAllAboutUsContent() async {
    try {
      final response = await _client
          .from('about_us_content')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AboutUsContent.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching about us content: $e');
      rethrow;
    }
  }

  Future<AboutUsContent?> fetchActiveAboutUsContent() async {
    try {
      final response = await _client
          .from('about_us_content')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      return AboutUsContent.fromJson(response);
    } catch (e) {
      print('Error fetching active about us content: $e');
      return null;
    }
  }

  Future<void> addAboutUsContent(AboutUsContent content) async {
    try {
      await _client.from('about_us_content').insert(content.toJson());
    } catch (e) {
      print('Error adding about us content: $e');
      rethrow;
    }
  }

  Future<void> updateAboutUsContent(AboutUsContent content) async {
    try {
      await _client
          .from('about_us_content')
          .update(content.toJson())
          .eq('id', content.id);
    } catch (e) {
      print('Error updating about us content: $e');
      rethrow;
    }
  }

  Future<void> deleteAboutUsContent(String id) async {
    try {
      await _client.from('about_us_content').delete().eq('id', id);
    } catch (e) {
      print('Error deleting about us content: $e');
      rethrow;
    }
  }
}
