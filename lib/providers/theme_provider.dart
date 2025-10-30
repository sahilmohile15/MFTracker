/// Theme Provider for managing app theme mode
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode preference key
const String _themeModeKey = 'theme_mode';

/// Theme mode enum for clarity
enum AppThemeMode {
  light,
  dark,
  system;

  /// Convert to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Convert from string
  static AppThemeMode fromString(String value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// Icon for UI
  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

/// Theme mode notifier that persists user preference
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.system) {
    _loadThemeMode();
  }

  /// Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);
      if (savedMode != null) {
        state = AppThemeMode.fromString(savedMode);
      }
    } catch (e) {
      // If loading fails, keep default (system)
      debugPrint('Error loading theme mode: $e');
    }
  }

  /// Set theme mode and persist preference
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Toggle between light and dark (ignores system)
  Future<void> toggleTheme() async {
    final newMode = state == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    await setThemeMode(newMode);
  }
}

/// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Convenience provider for Flutter's ThemeMode
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeModeProvider);
  return appThemeMode.toThemeMode();
});
