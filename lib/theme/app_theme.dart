import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/settings_provider.dart';

/// Escurece o esquema conforme o brilho da semente. 1 mantém as cores.
ColorScheme applySeedLuminosity(ColorScheme scheme, double value) {
  if (value >= 0.99) return scheme;
  final t = value.clamp(0.0, 1.0);
  Color shade(Color color) => Color.lerp(Colors.black, color, t)!;
  Color ink(Color color) => Color.lerp(Colors.white, color, t)!;
  return scheme.copyWith(
    primary: shade(scheme.primary),
    onPrimary: ink(scheme.onPrimary),
    secondary: shade(scheme.secondary),
    onSecondary: ink(scheme.onSecondary),
    tertiary: shade(scheme.tertiary),
    primaryContainer: shade(scheme.primaryContainer),
    secondaryContainer: shade(scheme.secondaryContainer),
    surface: shade(scheme.surface),
    onSurface: ink(scheme.onSurface),
    onSurfaceVariant: ink(scheme.onSurfaceVariant),
    surfaceContainerLow: shade(scheme.surfaceContainerLow),
    surfaceContainerHighest: shade(scheme.surfaceContainerHighest),
  );
}

ThemeData buildTheme(SettingsState s, Brightness brightness) {
  final hsv = HSVColor.fromColor(s.effectiveSeed);
  final vivid = s.preset == ThemePreset.custom ? hsv.withValue(1).toColor() : s.effectiveSeed;
  var scheme = ColorScheme.fromSeed(
    seedColor: vivid,
    brightness: brightness,
    dynamicSchemeVariant: s.schemeVariant,
  );
  if (s.preset == ThemePreset.custom) {
    scheme = applySeedLuminosity(scheme, hsv.value);
  }

  final base = brightness == Brightness.dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);

  TextTheme textTheme = switch (s.fontFamily) {
    AppFontFamily.roboto => GoogleFonts.robotoTextTheme(base.textTheme),
    AppFontFamily.garamond => GoogleFonts.ebGaramondTextTheme(base.textTheme),
    AppFontFamily.helvetica => GoogleFonts.openSansTextTheme(base.textTheme),
    AppFontFamily.mono => GoogleFonts.courierPrimeTextTheme(base.textTheme),
  };

  return base.copyWith(
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surfaceContainerLow,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      elevation: 0,
    ),
  );
}
