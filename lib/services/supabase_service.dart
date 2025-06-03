import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/environment.dart';
import '../core/error/app_error.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient client;

  Future<void> init() async {
    try {
      await Supabase.initialize(
        url: EnvironmentConfig.current.supabaseUrl,
        anonKey: EnvironmentConfig.current.supabaseAnonKey,
      );
      client = Supabase.instance.client;
    } catch (e, stackTrace) {
      throw AppError.database(
        'Failed to initialize Supabase: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e, stackTrace) {
      throw AppError.authentication(
        'Failed to sign out: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e, stackTrace) {
      throw AppError.authentication(
        'Failed to sign in: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e, stackTrace) {
      throw AppError.authentication(
        'Failed to sign up: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e, stackTrace) {
      throw AppError.authentication(
        'Failed to reset password: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e, stackTrace) {
      throw AppError.authentication(
        'Failed to update password: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  User? get currentUser => client.auth.currentUser;
}
