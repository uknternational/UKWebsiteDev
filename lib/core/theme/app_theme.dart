import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppConstants.midnightNavy,
        onPrimary: AppConstants.offWhite,
        secondary: AppConstants.copperBronze,
        onSecondary: AppConstants.offWhite,
        error: Colors.red,
        onError: Colors.white,
        surface: AppConstants.classicCream,
        onSurface: AppConstants.midnightNavy,
      ),
      scaffoldBackgroundColor: AppConstants.classicCream,
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        // Fallback fonts for better character coverage
        bodyLarge: GoogleFonts.notoSans(),
        bodyMedium: GoogleFonts.notoSans(),
        bodySmall: GoogleFonts.notoSans(),
        headlineLarge: GoogleFonts.notoSans(),
        headlineMedium: GoogleFonts.notoSans(),
        headlineSmall: GoogleFonts.notoSans(),
        titleLarge: GoogleFonts.notoSans(),
        titleMedium: GoogleFonts.notoSans(),
        titleSmall: GoogleFonts.notoSans(),
        labelLarge: GoogleFonts.notoSans(),
        labelMedium: GoogleFonts.notoSans(),
        labelSmall: GoogleFonts.notoSans(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.midnightNavy,
        foregroundColor: AppConstants.offWhite,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.copperBronze,
          foregroundColor: AppConstants.offWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
