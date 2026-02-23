import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'app_theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_themeKey);
    if (stored == ThemeMode.dark.name) {
      return ThemeMode.dark;
    }
    return ThemeMode.light;
  }

  Future<void> setDarkMode(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = enabled ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString(_themeKey, state.name);
  }
}
