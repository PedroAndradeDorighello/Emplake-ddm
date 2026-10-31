import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/difficulty.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/custom_loader.dart';
import '../widgets/forge_board.dart';
import '../widgets/latex_preview.dart';
import '../widgets/leave_button.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  String _feedback(AppLocalizations l10n, VerifyFeedback f) => switch (f) {
        VerifyFeedback.none => '',
        VerifyFeedback.correct => l10n.correct,
        VerifyFeedback.incorrect => l10n.incorrect,
        VerifyFeedback.invalid => l10n.invalidExpression,
        VerifyFeedback.missingEquals => l10n.missingEquals,
        VerifyFeedback.nonIntegerDivision => l10n.nonIntegerDivision,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameProvider);
    final auth = ref.watch(authProvider);
    final scheme = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 800;

    if (game.loading) {
      return ForgeLoader(message: l10n.loadingProgress);
    }

    final body = Column(
      children: [
        if (auth?.isGuest == true)
          Container(
            width: double.infinity,
            color: scheme.secondaryContainer.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(l10n.guestBanner, style: Theme.of(context).textTheme.bodySmall),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Text(
                '${l10n.puzzleNumber}: ${game.puzzle.number}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Text('${l10n.score}: ${game.progress.score}'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.difficulty),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final d in Difficulty.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(switch (d) {
                      Difficulty.easy => l10n.easy,
                      Difficulty.intermediate => l10n.intermediate,
                      Difficulty.advanced => l10n.advanced,
                      Difficulty.hard => l10n.hard,
                    }),
                    selected: game.puzzle.difficulty == d,
                    onSelected: (_) =>
                        ref.read(gameProvider.notifier).setDifficulty(d),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.selectSlot,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ForgeBoard(
            puzzle: game.puzzle,
            resetKey: game.resetAnim,
            onSelect: ref.read(gameProvider.notifier).selectSlot,
            onDrop: ref.read(gameProvider.notifier).drop,
            onRemove: ref.read(gameProvider.notifier).removePlaced,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          game.puzzle.displayExpression,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'monospace',
              ),
        ),
        const SizedBox(height: 8),
        LatexPreview(expression: game.puzzle.displayExpression),
        if (game.feedback != VerifyFeedback.none)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _feedback(l10n, game.feedback),
              style: TextStyle(
                color: game.feedback == VerifyFeedback.correct
                    ? scheme.primary
                    : scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.operatorsForLevel),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OperatorStamps(
              operators: game.puzzle.difficulty.operators,
              onStamp: ref.read(gameProvider.notifier).stamp,
              onBackspace: ref.read(gameProvider.notifier).backspace,
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(gameProvider.notifier).clearOps(),
                    child: Text(l10n.clear),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(gameProvider.notifier).skip(),
                    child: Text(l10n.skip),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => ref.read(gameProvider.notifier).verify(),
                    child: Text(l10n.verify),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [LeaveButton()],
      ),
      body: wide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: body,
              ),
            )
          : body,
    );
  }
}
