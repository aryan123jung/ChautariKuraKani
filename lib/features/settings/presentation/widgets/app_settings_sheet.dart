import 'package:chautari_kurakani/features/settings/presentation/state/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeModeProvider);
    final isDark = themeState.effectiveMode == ThemeMode.dark;

    final gradient = isDark
        ? const [Color(0xFF1B2330), Color(0xFF121821)]
        : const [Color(0xFFF7FBFF), Color(0xFFEFF7EF)];

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF273449)
                          : const Color(0xFFE7F0FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isDark ? Icons.nights_stay : Icons.wb_sunny_rounded,
                      color: isDark
                          ? const Color(0xFFB5CCFF)
                          : const Color(0xFF2E6BFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF131620),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            themeState.preference == ThemePreference.auto
                                ? themeState.sensorAvailable
                                      ? 'Auto by ambient light sensor'
                                      : 'Auto follows system appearance on this device'
                                : (isDark
                                      ? 'Comfortable for low-light viewing'
                                      : 'Bright and clear daytime look'),
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF5D6675),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemePreference>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<ThemePreference>(
                    value: ThemePreference.auto,
                    icon: Icon(Icons.sensors_outlined),
                    label: Text('Auto'),
                  ),
                  ButtonSegment<ThemePreference>(
                    value: ThemePreference.light,
                    icon: Icon(Icons.wb_sunny_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment<ThemePreference>(
                    value: ThemePreference.dark,
                    icon: Icon(Icons.nightlight_round),
                    label: Text('Dark'),
                  ),
                ],
                selected: {themeState.preference},
                onSelectionChanged: (selected) {
                  final value = selected.first;
                  ref.read(themeModeProvider.notifier).setPreference(value);
                },
              ),
              if (themeState.preference == ThemePreference.auto &&
                  themeState.sensorAvailable &&
                  themeState.lux != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Ambient light: ${themeState.lux} lux',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF4A5668),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
