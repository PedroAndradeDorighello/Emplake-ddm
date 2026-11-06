import 'package:emplake/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile stores theme, font, language and last screen', () {
    const original = SettingsState(
      themeMode: ThemeMode.dark,
      fontSize: 18,
      fontFamily: AppFontFamily.mono,
      preset: ThemePreset.ember,
      schemeVariant: DynamicSchemeVariant.fruitSalad,
      locale: Locale('en'),
    );

    final map = profileFields(original, lastRoute: '/settings');
    final restored = applyProfile(const SettingsState(), map);

    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.fontSize, 18);
    expect(restored.fontFamily, AppFontFamily.mono);
    expect(restored.preset, ThemePreset.ember);
    expect(restored.schemeVariant, DynamicSchemeVariant.fruitSalad);
    expect(restored.locale.languageCode, 'en');
    expect(profileLastRoute(map), '/settings');
  });

  test('a progress-only profile leaves the current style alone', () {
    const base = SettingsState(schemeVariant: DynamicSchemeVariant.rainbow);
    final restored = applyProfile(base, const {'score': 3});
    expect(restored.schemeVariant, DynamicSchemeVariant.rainbow);
    expect(profileLastRoute(const {'score': 3}), isNull);
  });
}
