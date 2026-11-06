import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../widgets/leave_button.dart';
import '../widgets/seed_color_wheel.dart';

String _schemeLabel(AppLocalizations l10n, DynamicSchemeVariant variant) {
  return switch (variant) {
    DynamicSchemeVariant.tonalSpot => l10n.schemeTonalSpot,
    DynamicSchemeVariant.fidelity => l10n.schemeFidelity,
    DynamicSchemeVariant.monochrome => l10n.schemeMonochrome,
    DynamicSchemeVariant.neutral => l10n.schemeNeutral,
    DynamicSchemeVariant.vibrant => l10n.schemeVibrant,
    DynamicSchemeVariant.expressive => l10n.schemeExpressive,
    DynamicSchemeVariant.content => l10n.schemeContent,
    DynamicSchemeVariant.rainbow => l10n.schemeRainbow,
    DynamicSchemeVariant.fruitSalad => l10n.schemeFruitSalad,
  };
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: const [LeaveButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.themeMode, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
              ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => n.setThemeMode(v.first),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              avatar: Icon(s.soundEnabled ? Icons.volume_up : Icons.volume_off),
              label: Text('${l10n.sound}: ${s.soundEnabled ? l10n.soundOn : l10n.soundOff}'),
              selected: s.soundEnabled,
              onSelected: n.setSound,
            ),
          ),
          const SizedBox(height: 24),
          Text('${l10n.fontSize}: ${s.fontSize.toStringAsFixed(0)}'),
          Slider(
            min: 12,
            max: 22,
            divisions: 10,
            value: s.fontSize,
            onChanged: n.setFontSize,
          ),
          const SizedBox(height: 8),
          Text(l10n.fontFamily, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final f in AppFontFamily.values)
                ChoiceChip(
                  label: Text(switch (f) {
                    AppFontFamily.roboto => l10n.fontRoboto,
                    AppFontFamily.garamond => l10n.fontGaramond,
                    AppFontFamily.helvetica => l10n.fontHelvetica,
                    AppFontFamily.mono => l10n.fontMono,
                  }),
                  selected: s.fontFamily == f,
                  onSelected: (_) => n.setFontFamily(f),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.presetTheme, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in ThemePreset.values)
                ChoiceChip(
                  label: Text(switch (p) {
                    ThemePreset.ocean => l10n.presetOcean,
                    ThemePreset.ember => l10n.presetEmber,
                    ThemePreset.forest => l10n.presetForest,
                    ThemePreset.slate => l10n.presetSlate,
                    ThemePreset.custom => l10n.presetCustom,
                    ThemePreset.systemSeed => l10n.themeSystem,
                  }),
                  selected: s.preset == p,
                  onSelected: (_) => n.setPreset(p),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ExpansionTile(
            title: Text(l10n.moreThemeOptions),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.schemeStyle, style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final variant in DynamicSchemeVariant.values)
                    ChoiceChip(
                      label: Text(_schemeLabel(l10n, variant)),
                      selected: s.schemeVariant == variant,
                      onSelected: (_) => n.setScheme(variant),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.seedColor, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Center(
                child: SeedColorWheel(
                  color: s.effectiveSeed,
                  onChanged: (c) => n.setSeedColor(c, persist: false),
                  onChangeEnd: n.setSeedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
