import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagebible/core/services/storage_service.dart';
import 'package:sagebible/features/auth/providers/auth_provider.dart';

/// Theme Mode Notifier
/// 
/// Manages app theme (light/dark) with persistence
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;
  static const String _themeKey = 'theme_mode';

  ThemeModeNotifier(this._storage) : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    final savedTheme = _storage.getString(_themeKey);
    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.light,
      );
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _storage.setString(_themeKey, state.toString());
  }

  /// Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.setString(_themeKey, state.toString());
  }

  /// Check if dark mode is active
  bool get isDarkMode => state == ThemeMode.dark;
}

/// Provider for ThemeModeNotifier
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});

/// Convenience provider to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeModeProvider) == ThemeMode.dark;
});
