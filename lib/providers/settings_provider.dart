import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFontFamily { roboto, garamond, helvetica, mono }

enum ThemePreset { systemSeed, ocean, ember, forest, slate, custom }

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.fontSize = 16,
    this.fontFamily = AppFontFamily.roboto,
    this.seedColor = const Color(0xFF0D7377),
    this.preset = ThemePreset.systemSeed,
    this.soundEnabled = false,
    this.locale = const Locale('pt'),
  });

  final ThemeMode themeMode;
  final double fontSize;
  final AppFontFamily fontFamily;
  final Color seedColor;
  final ThemePreset preset;
  final bool soundEnabled;
  final Locale locale;

  Color get effectiveSeed => switch (preset) {
        ThemePreset.ocean => const Color(0xFF0D7377),
        ThemePreset.ember => const Color(0xFFB85C38),
        ThemePreset.forest => const Color(0xFF2D6A4F),
        ThemePreset.slate => const Color(0xFF4A5568),
        ThemePreset.systemSeed => const Color(0xFF6750A4),
        ThemePreset.custom => seedColor,
      };

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    AppFontFamily? fontFamily,
    Color? seedColor,
    ThemePreset? preset,
    bool? soundEnabled,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      seedColor: seedColor ?? this.seedColor,
      preset: preset ?? this.preset,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final mode = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
    final fontSize = _prefs.getDouble('fontSize') ?? 16;
    final font = AppFontFamily.values[_prefs.getInt('fontFamily') ?? 0];
    final seed = Color(_prefs.getInt('seedColor') ?? 0xFF0D7377);
    final preset = ThemePreset.values[_prefs.getInt('preset') ?? 0];
    final sound = _prefs.getBool('sound') ?? false;
    final lang = _prefs.getString('locale') ?? 'pt';
    state = SettingsState(
      themeMode: mode,
      fontSize: fontSize,
      fontFamily: font,
      seedColor: seed,
      preset: preset,
      soundEnabled: sound,
      locale: Locale(lang),
    );
  }

  Future<void> _persist() async {
    await _prefs.setInt('themeMode', state.themeMode.index);
    await _prefs.setDouble('fontSize', state.fontSize);
    await _prefs.setInt('fontFamily', state.fontFamily.index);
    await _prefs.setInt('seedColor', state.seedColor.toARGB32());
    await _prefs.setInt('preset', state.preset.index);
    await _prefs.setBool('sound', state.soundEnabled);
    await _prefs.setString('locale', state.locale.languageCode);
  }

  void setThemeMode(ThemeMode m) {
    state = state.copyWith(themeMode: m);
    _persist();
  }

  void setFontSize(double v) {
    state = state.copyWith(fontSize: v);
    _persist();
  }

  void setFontFamily(AppFontFamily f) {
    state = state.copyWith(fontFamily: f);
    _persist();
  }

  void setSeedColor(Color c, {bool persist = true}) {
    state = state.copyWith(seedColor: c, preset: ThemePreset.custom);
    if (persist) _persist();
  }

  void setPreset(ThemePreset p) {
    state = state.copyWith(preset: p);
    _persist();
  }

  void setSound(bool on) {
    state = state.copyWith(soundEnabled: on);
    _persist();
  }

  void setLocale(Locale l) {
    state = state.copyWith(locale: l);
    _persist();
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('override in main');
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(sharedPrefsProvider));
});
