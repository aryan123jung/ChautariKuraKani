import 'dart:async';
import 'dart:io';

import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/sensor/data/services/ambient_light_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemePreference { auto, light, dark }

class ThemeModeState {
  final ThemePreference preference;
  final ThemeMode effectiveMode;
  final bool sensorActive;
  final bool sensorAvailable;
  final int? lux;

  const ThemeModeState({
    required this.preference,
    required this.effectiveMode,
    required this.sensorActive,
    required this.sensorAvailable,
    required this.lux,
  });

  ThemeModeState copyWith({
    ThemePreference? preference,
    ThemeMode? effectiveMode,
    bool? sensorActive,
    bool? sensorAvailable,
    int? lux,
    bool clearLux = false,
  }) {
    return ThemeModeState(
      preference: preference ?? this.preference,
      effectiveMode: effectiveMode ?? this.effectiveMode,
      sensorActive: sensorActive ?? this.sensorActive,
      sensorAvailable: sensorAvailable ?? this.sensorAvailable,
      lux: clearLux ? null : (lux ?? this.lux),
    );
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeModeState>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeModeState> {
  static const _themeKey = 'app_theme_preference';

  final AmbientLightService _ambientLightService = AmbientLightService();
  StreamSubscription<int>? _luxSub;
  bool _autoDark = false;
  double? _emaLux;
  double? _baselineLux;

  @override
  ThemeModeState build() {
    ref.onDispose(_disposeSensor);
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_themeKey);
    final preference = _parsePreference(stored);
    final initialMode = _themeForPreference(preference);

    final initial = ThemeModeState(
      preference: preference,
      effectiveMode: initialMode,
      sensorActive: false,
      sensorAvailable: false,
      lux: null,
    );

    if (preference == ThemePreference.auto) {
      Future.microtask(_startAmbientAutoMode);
    }

    return initial;
  }

  Future<void> setPreference(ThemePreference preference) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeKey, preference.name);

    if (preference == ThemePreference.auto) {
      state = state.copyWith(preference: preference, sensorActive: true);
      await _startAmbientAutoMode();
      return;
    }

    _disposeSensor();
    state = state.copyWith(
      preference: preference,
      effectiveMode: _themeForPreference(preference),
      sensorActive: false,
      clearLux: true,
    );
  }

  void syncWithSystemAppearance() {
    if (state.preference != ThemePreference.auto) return;
    // In sensor mode (Android), ambient lux should drive the theme.
    // In fallback mode (iOS / unavailable), follow system immediately.
    if (state.sensorAvailable) return;
    state = state.copyWith(
      effectiveMode: _themeForPreference(ThemePreference.auto),
    );
  }

  ThemePreference _parsePreference(String? raw) {
    switch (raw) {
      case 'dark':
        return ThemePreference.dark;
      case 'auto':
        return ThemePreference.auto;
      case 'light':
      default:
        return ThemePreference.light;
    }
  }

  ThemeMode _themeForPreference(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.auto:
        final platformBrightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return platformBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light;
    }
  }

  Future<void> _startAmbientAutoMode() async {
    _disposeSensor();
    _autoDark = state.effectiveMode == ThemeMode.dark;
    _emaLux = null;
    _baselineLux = null;
    // iOS does not reliably expose ambient light sensor readings to
    // third-party apps. Fallback to system appearance in auto mode.
    if (Platform.isIOS) {
      state = state.copyWith(
        sensorActive: false,
        sensorAvailable: false,
        effectiveMode: _themeForPreference(ThemePreference.auto),
        clearLux: true,
      );
      return;
    }

    state = state.copyWith(sensorActive: true, sensorAvailable: true);

    _luxSub = _ambientLightService.luxStream().listen(
      (lux) {
        final shouldDarken = _computeAutoDarkWithHysteresis(lux);
        state = state.copyWith(
          sensorAvailable: true,
          lux: lux,
          effectiveMode: shouldDarken ? ThemeMode.dark : ThemeMode.light,
        );
      },
      onError: (_) {
        state = state.copyWith(
          sensorActive: false,
          sensorAvailable: false,
          effectiveMode: _themeForPreference(ThemePreference.light),
          clearLux: true,
        );
      },
      cancelOnError: false,
    );
  }

  bool _computeAutoDarkWithHysteresis(int lux) {
    const darkThreshold = 55;
    const lightThreshold = 140;
    final sanitizedLux = lux < 0 ? 0 : lux;
    _emaLux = _emaLux == null
        ? sanitizedLux.toDouble()
        : (_emaLux! * 0.75) + (sanitizedLux * 0.25);
    final currentLux = _emaLux!;
    _baselineLux ??= currentLux;
    _baselineLux = (_baselineLux! * 0.985) + (currentLux * 0.015);

    if (state.lux == null) {
      _autoDark = currentLux <= ((darkThreshold + lightThreshold) / 2);
      return _autoDark;
    }

    final darkerThanBaseline = currentLux <= (_baselineLux! * 0.62);
    final brighterThanBaseline = currentLux >= (_baselineLux! * 1.45);

    if (!_autoDark && (currentLux <= darkThreshold || darkerThanBaseline)) {
      _autoDark = true;
    } else if (_autoDark &&
        (currentLux >= lightThreshold || brighterThanBaseline)) {
      _autoDark = false;
    }

    return _autoDark;
  }

  void _disposeSensor() {
    _luxSub?.cancel();
    _luxSub = null;
  }
}
