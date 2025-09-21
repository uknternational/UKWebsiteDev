import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart' as app_models;
import 'supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _client = SupabaseService().client;

  // Get current user
  app_models.User? get currentUser {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser != null) {
      return app_models.User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        name: supabaseUser.userMetadata?['name'],
        createdAt: DateTime.parse(supabaseUser.createdAt),
      );
    }
    return null;
  }

  // Check if user is logged in
  bool get isLoggedIn => _client.auth.currentUser != null;

  // Sign up with email and password
  Future<app_models.User> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw Exception('Failed to create user');
      }

      return app_models.User(
        id: response.user!.id,
        email: response.user!.email ?? email,
        name: name,
        createdAt: DateTime.parse(response.user!.createdAt),
      );
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<app_models.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      return app_models.User(
        id: response.user!.id,
        email: response.user!.email ?? email,
        name: response.user!.userMetadata?['name'],
        createdAt: DateTime.parse(response.user!.createdAt),
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Listen to auth state changes
  Stream<app_models.User?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user != null) {
        return app_models.User(
          id: user.id,
          email: user.email ?? '',
          name: user.userMetadata?['name'],
          createdAt: DateTime.parse(user.createdAt),
        );
      }
      return null;
    });
  }

  // Send confirmation email (resend)
  Future<void> sendConfirmationEmail(String email) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
    } catch (e) {
      throw Exception('Failed to resend confirmation email: $e');
    }
  }
}
