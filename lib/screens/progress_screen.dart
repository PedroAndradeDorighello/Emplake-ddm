import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/user_progress.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../services/latex_converter.dart';
import '../services/progress_repository.dart';
import '../services/solution_steps.dart';
import '../theme/screen_scale.dart';
import '../widgets/custom_loader.dart';
import '../widgets/leave_button.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  Future<void> _showSolution(
    BuildContext context,
    int number,
    SavedSolution? saved,
  ) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final fontSize = ScreenScale.of(context).compact ? 18.0 : 24.0;
    final expr = saved?.expression;
    final latex =
        expr == null || expr.isEmpty ? null : expressionToLatex(expr);
    final steps = latex == null || saved == null
        ? const <String>[]
        : solutionLatexSteps(expr!, saved.difficulty);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('${l10n.yourSolution} · $number'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: latex == null
                  ? Text(l10n.noSolutionSaved)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MathLine(
                          latex: latex,
                          fontSize: fontSize,
                          color: scheme.onSurface,
                        ),
                        if (steps.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.showSolutionSteps,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: scheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          for (var i = 0; i < steps.length; i++) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                top: 4,
                                bottom: 2,
                              ),
                              child: Text(
                                '⇒',
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _MathLine(
                              latex: steps[i],
                              fontSize: fontSize * 0.85,
                              color: i == steps.length - 1
                                  ? scheme.primary
                                  : scheme.onSurface,
                            ),
                          ],
                        ],
                      ],
                    ),
            ),
          ),
          actions: [
            if (latex != null)
              TextButton.icon(
                onPressed: () async {
                  final all = [
                    latex,
                    if (steps.isNotEmpty) ...[
                      '',
                      for (final s in steps) '⇒ $s',
                    ],
                  ].join('\n');
                  await Clipboard.setData(ClipboardData(text: all));
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(l10n.latexCopied),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: Text(l10n.copyLatex),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(MaterialLocalizations.of(ctx).closeButtonLabel),
            ),
          ],
        );
      },
    );
  }

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
          final progress = live.mergeWith(remote);
          // Mais recente primeiro.
          final solved = progress.solved.reversed.toList();
          final skipped = progress.skipped.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatRow(label: l10n.score, value: '${progress.score}'),
              _StatRow(label: l10n.solvedCount, value: '${solved.length}'),
              _StatRow(label: l10n.skippedCount, value: '${skipped.length}'),
              const SizedBox(height: 16),
              Text(l10n.solvedCount, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                l10n.tapSolvedHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (solved.isEmpty)
                Text(l10n.noSolvedYet)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final n in solved)
                      ActionChip(
                        label: Text('$n'),
                        avatar: progress.solutions.containsKey(n)
                            ? const Icon(Icons.functions, size: 16)
                            : null,
                        onPressed: () => _showSolution(
                          context,
                          n,
                          progress.solutions[n],
                        ),
                      ),
                  ],
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

class _MathLine extends StatelessWidget {
  const _MathLine({
    required this.latex,
    required this.fontSize,
    required this.color,
  });

  final String latex;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        latex,
        mathStyle: MathStyle.display,
        textStyle: TextStyle(fontSize: fontSize, color: color),
        onErrorFallback: (_) => SelectableText(
          latex,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
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
