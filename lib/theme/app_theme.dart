/// MFTracker App Theme
/// Based on STYLE_GUIDE.md - Trustworthy · Minimal · Open · Private
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color scheme based on style guide
class AppColors {
  // Primary Colors
  static const Color primaryTeal = Color(0xFF00796B);
  static const Color accentEmerald = Color(0xFF2ECC71);
  static const Color neutralDarkCharcoal = Color(0xFF263238);
  static const Color neutralLightWhite = Color(0xFFFFFFFF);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF1C1C1C);
  static const Color lightSecondaryText = Color(0xFF5A5A5A);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimaryText = Color(0xFFEAEAEA);
  static const Color darkSecondaryText = Color(0xFFA0A0A0);
  static const Color darkDivider = Color(0xFF2C2C2C);

  // Optional Accent Variations (5-10% usage)
  static const Color blueVariant = Color(0xFF1E88E5); // Analytics/charts
  static const Color orangeVariant = Color(0xFFFB8C00); // Notifications/alerts

  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF1E88E5);
}

/// Light theme configuration
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryTeal,
        secondary: AppColors.accentEmerald,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightPrimaryText,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.lightBackground,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightPrimaryText,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightPrimaryText,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          side: const BorderSide(color: AppColors.primaryTeal),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.lightSecondaryText,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentEmerald,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: AppColors.lightSecondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: AppColors.lightPrimaryText,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightDivider,
        selectedColor: AppColors.primaryTeal.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          color: AppColors.lightPrimaryText,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightPrimaryText,
        ),
      ),

      // Text Theme with Inter font family
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          // Headers
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.lightPrimaryText,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.lightPrimaryText,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.lightPrimaryText,
          ),

          // Titles
          headlineLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightPrimaryText,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightPrimaryText,
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.lightPrimaryText,
          ),

          // Body
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.lightPrimaryText,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.lightPrimaryText,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.lightSecondaryText,
          ),

          // Labels (buttons, etc.)
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.lightPrimaryText,
          ),
          labelMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.lightPrimaryText,
          ),
          labelSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: AppColors.lightSecondaryText,
          ),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentEmerald,
        secondary: AppColors.primaryTeal,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkPrimaryText,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.darkBackground,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkPrimaryText,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryText,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentEmerald,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentEmerald,
          side: const BorderSide(color: AppColors.accentEmerald),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentEmerald,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentEmerald, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.darkSecondaryText,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentEmerald,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.accentEmerald,
        unselectedItemColor: AppColors.darkSecondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: AppColors.darkPrimaryText,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkDivider,
        selectedColor: AppColors.accentEmerald.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          color: AppColors.darkPrimaryText,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryText,
        ),
      ),

      // Text Theme with Inter font family
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          // Headers
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.darkPrimaryText,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.darkPrimaryText,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.darkPrimaryText,
          ),

          // Titles
          headlineLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.darkPrimaryText,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkPrimaryText,
          ),
          headlineSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkPrimaryText,
          ),

          // Body
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.darkPrimaryText,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.darkPrimaryText,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.darkSecondaryText,
          ),

          // Labels (buttons, etc.)
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkPrimaryText,
          ),
          labelMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkPrimaryText,
          ),
          labelSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: AppColors.darkSecondaryText,
          ),
        ),
      ),
    );
  }
}
