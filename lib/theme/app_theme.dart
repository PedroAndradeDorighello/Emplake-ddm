import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/settings_provider.dart';

ThemeData buildTheme(SettingsState s, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: s.effectiveSeed,
    brightness: brightness,
    dynamicSchemeVariant: s.schemeVariant,
  );

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
