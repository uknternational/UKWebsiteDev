import 'package:flutter/material.dart';

class AppConstants {
  // API Constants
  static const String supabaseUrl = 'https://hefmjgtblqxclbbtvckb.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhlZm1qZ3RibHF4Y2xiYnR2Y2tiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4MDQ3MTIsImV4cCI6MjA2NDM4MDcxMn0.tuP2qrfy9eMAKLSLe4DLov5xx5QBIKhZZxYRiZHQ63E';

  // Color Palette
  static const Color midnightNavy = Color(0xFF0C1B33);
  static const Color classicCream = Color(0xFFECD9B0);
  static const Color copperBronze = Color(0xFFA9744F);
  static const Color offWhite = Color(0xFFF8F5EF);

  // Contact Information
  static const String businessEmail = 'ukinternationalperfumes@gmail.com';
  static const String instagramHandle = '_uk_international';
  static const String whatsappNumber = '7600662616';
  static const String whatsappUrl = 'https://wa.me/917600662616';

  // Routes
  static const String homeRoute = '/';
  static const String adminRoute = '/admin';
  static const String productDetailsRoute = '/product';
  static const String cartRoute = '/cart';
  static const String wishlistRoute = '/wishlist';

  // Storage Keys
  static const String cartStorageKey = 'cart_items';
  static const String wishlistStorageKey = 'wishlist_items';
  static const String adminTokenKey = 'admin_token';

  // Placeholder Image
  static const String placeholderImage = 'https://via.placeholder.com/400';
} 