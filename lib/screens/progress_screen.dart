import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/user_progress.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/custom_loader.dart';
import '../widgets/leave_button.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authProvider)?.uid ?? 'guest_local';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProgress),
        actions: const [LeaveButton()],
      ),
      body: FutureBuilder<UserProgress>(
        // FutureBuilder obrigatório + indicador custom (ForgeLoader)
        future: ref.read(progressRepositoryProvider).load(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ForgeLoader(message: l10n.loadingProgress);
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final remote = snapshot.data ?? const UserProgress();
          final live = ref.watch(gameProvider).progress;
          final progress = live.score >= remote.score ? live : remote;
          final solved = progress.solved.toList()..sort();
          final skipped = progress.skipped.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatRow(label: l10n.score, value: '${progress.score}'),
              _StatRow(label: l10n.solvedCount, value: '${solved.length}'),
              _StatRow(label: l10n.skippedCount, value: '${skipped.length}'),
              const SizedBox(height: 16),
              Text(l10n.solvedCount, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (solved.isEmpty)
                Text(l10n.noSolvedYet)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final n in solved) Chip(label: Text('$n'))],
                ),
              const SizedBox(height: 24),
              Text(l10n.skippedCount, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final n in skipped)
                    Chip(
                      label: Text('$n'),
                      avatar: const Icon(Icons.skip_next, size: 16),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
