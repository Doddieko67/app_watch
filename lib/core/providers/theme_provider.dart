import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

// Estado del tema
class ThemeState {
  final ThemeMode themeMode;
  final Color seedColor;

  const ThemeState({
    required this.themeMode,
    required this.seedColor,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _seedColorKey = 'seed_color';

  @override
  ThemeState build() {
    _loadTheme();
    return const ThemeState(
      themeMode: ThemeMode.system,
      seedColor: Colors.blue,
    );
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar ThemeMode
    final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
    final themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeString,
      orElse: () => ThemeMode.system,
    );

    // Cargar SeedColor
    final colorValue = prefs.getInt(_seedColorKey) ?? 0xFF2196F3; // Colors.blue
    final seedColor = Color(colorValue);

    state = ThemeState(
      themeMode: themeMode,
      seedColor: seedColor,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.value);
    state = state.copyWith(seedColor: color);
  }

  // Getter para color value
  int _getColorValue(Color color) {
    return (color.a.toInt() << 24) |
        (color.r.toInt() << 16) |
        (color.g.toInt() << 8) |
        color.b.toInt();
  }
}
