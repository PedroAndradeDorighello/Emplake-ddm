import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../widgets/leave_button.dart';

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
          const SizedBox(height: 24),
          Text(l10n.seedColor, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              for (final c in const [
                Color(0xFF0D7377),
                Color(0xFFB85C38),
                Color(0xFF2D6A4F),
                Color(0xFF4A5568),
                Color(0xFF1B4965),
                Color(0xFF9A3412),
              ])
                InkWell(
                  onTap: () => n.setSeedColor(c),
                  child: CircleAvatar(
                    backgroundColor: c,
                    radius: 16,
                    child: s.seedColor.toARGB32() == c.toARGB32()
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
            ],
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
          SwitchListTile(
            title: Text(l10n.sound),
            subtitle: Text(s.soundEnabled ? l10n.soundOn : l10n.soundOff),
            value: s.soundEnabled,
            onChanged: n.setSound,
          ),
        ],
      ),
    );
  }
}
