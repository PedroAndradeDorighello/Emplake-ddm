import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/progress_repository.dart';
import 'auth_provider.dart';

enum AppFontFamily { roboto, garamond, helvetica, mono }

enum ThemePreset { systemSeed, ocean, ember, forest, slate, custom }

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.fontSize = 16,
    this.fontFamily = AppFontFamily.roboto,
    this.seedColor = const Color(0xFF0D7377),
    this.preset = ThemePreset.systemSeed,
    this.schemeVariant = DynamicSchemeVariant.tonalSpot,
    this.soundEnabled = false,
    this.locale = const Locale('pt'),
  });

  final ThemeMode themeMode;
  final double fontSize;
  final AppFontFamily fontFamily;
  final Color seedColor;
  final ThemePreset preset;
  final DynamicSchemeVariant schemeVariant;
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
    DynamicSchemeVariant? schemeVariant,
    bool? soundEnabled,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      seedColor: seedColor ?? this.seedColor,
      preset: preset ?? this.preset,
      schemeVariant: schemeVariant ?? this.schemeVariant,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      locale: locale ?? this.locale,
    );
  }
}

/// Campos de tema, fonte, idioma e última tela gravados em `users/{uid}`.
Map<String, dynamic> profileFields(SettingsState s, {String? lastRoute}) => {
      'themeMode': s.themeMode.name,
      'fontSize': s.fontSize,
      'fontFamily': s.fontFamily.name,
      'seedColor': s.seedColor.toARGB32(),
      'preset': s.preset.name,
      'scheme': s.schemeVariant.name,
      'locale': s.locale.languageCode,
      'lastRoute': ?lastRoute,
    };

T? _enumByName<T extends Enum>(List<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}

SettingsState applyProfile(SettingsState base, Map<String, dynamic> map) {
  final lang = map['locale'];
  return base.copyWith(
    themeMode: _enumByName(ThemeMode.values, map['themeMode']),
    fontSize: (map['fontSize'] as num?)?.toDouble(),
    fontFamily: _enumByName(AppFontFamily.values, map['fontFamily']),
    seedColor: map['seedColor'] is num ? Color((map['seedColor'] as num).toInt()) : null,
    preset: _enumByName(ThemePreset.values, map['preset']),
    schemeVariant: _enumByName(DynamicSchemeVariant.values, map['scheme']),
    locale: lang is String && lang.isNotEmpty ? Locale(lang) : null,
  );
}

String? profileLastRoute(Map<String, dynamic> map) {
  final route = map['lastRoute'];
  if (route is! String || route == '/login' || !route.startsWith('/')) return null;
  return route;
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._ref, this._prefs) : super(const SettingsState()) {
    _load();
  }

  final Ref _ref;
  final SharedPreferences _prefs;

  void _load() {
    final mode = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
    final fontSize = _prefs.getDouble('fontSize') ?? 16;
    final font = AppFontFamily.values[_prefs.getInt('fontFamily') ?? 0];
    final seed = Color(_prefs.getInt('seedColor') ?? 0xFF0D7377);
    final preset = ThemePreset.values[_prefs.getInt('preset') ?? 0];
    final scheme = _enumByName(DynamicSchemeVariant.values, _prefs.getString('scheme')) ??
        DynamicSchemeVariant.tonalSpot;
    final sound = _prefs.getBool('sound') ?? false;
    final lang = _prefs.getString('locale') ?? 'pt';
    state = SettingsState(
      themeMode: mode,
      fontSize: fontSize,
      fontFamily: font,
      seedColor: seed,
      preset: preset,
      schemeVariant: scheme,
      soundEnabled: sound,
      locale: Locale(lang),
    );
  }

  Future<void> _writeLocal() async {
    await _prefs.setInt('themeMode', state.themeMode.index);
    await _prefs.setDouble('fontSize', state.fontSize);
    await _prefs.setInt('fontFamily', state.fontFamily.index);
    await _prefs.setInt('seedColor', state.seedColor.toARGB32());
    await _prefs.setInt('preset', state.preset.index);
    await _prefs.setString('scheme', state.schemeVariant.name);
    await _prefs.setBool('sound', state.soundEnabled);
    await _prefs.setString('locale', state.locale.languageCode);
  }

  Future<void> _persist() async {
    await _writeLocal();
    final auth = _ref.read(authProvider);
    if (auth == null || auth.isGuest) return;
    await _ref.read(progressRepositoryProvider).mergeProfile(
          auth.uid,
          profileFields(state, lastRoute: _prefs.getString('last_route')),
        );
  }

  /// Aplica o perfil da nuvem. Devolve a última tela, se houver.
  Future<String?> pullProfile(String uid) async {
    final map = await _ref.read(progressRepositoryProvider).readProfile(uid);
    if (map == null) return null;
    state = applyProfile(state, map);
    await _writeLocal();
    final route = profileLastRoute(map);
    if (route != null) await _prefs.setString('last_route', route);
    return route;
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

  void setScheme(DynamicSchemeVariant variant) {
    state = state.copyWith(schemeVariant: variant);
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
  return SettingsNotifier(ref, ref.watch(sharedPrefsProvider));
});
