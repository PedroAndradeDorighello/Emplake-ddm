import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/difficulty.dart';
import '../models/puzzle_state.dart';
import '../models/user_progress.dart';
import '../services/expression_evaluator.dart';
import '../services/progress_repository.dart';
import '../services/puzzle_generator.dart';
import '../services/sound_service.dart';
import 'auth_provider.dart';
import 'settings_provider.dart';

enum VerifyFeedback { none, correct, incorrect, invalid, missingEquals, nonIntegerDivision }

class GameViewState {
  GameViewState({
    required this.puzzle,
    required this.progress,
    this.feedback = VerifyFeedback.none,
    this.resetAnim = 0,
    this.loading = false,
  });

  final PuzzleState puzzle;
  final UserProgress progress;
  final VerifyFeedback feedback;
  final int resetAnim;
  final bool loading;

  GameViewState copyWith({
    PuzzleState? puzzle,
    UserProgress? progress,
    VerifyFeedback? feedback,
    int? resetAnim,
    bool? loading,
  }) {
    return GameViewState(
      puzzle: puzzle ?? this.puzzle,
      progress: progress ?? this.progress,
      feedback: feedback ?? this.feedback,
      resetAnim: resetAnim ?? this.resetAnim,
      loading: loading ?? this.loading,
    );
  }
}

class GameNotifier extends StateNotifier<GameViewState> {
  GameNotifier(this._ref, this._repo, this._sound)
      : super(GameViewState(
          puzzle: PuzzleState(
            digits: const [3, 4, 5, 6],
            difficulty: Difficulty.easy,
          ),
          progress: const UserProgress(),
          loading: true,
        )) {
    _bootstrap();
  }

  final Ref _ref;
  final ProgressRepository _repo;
  final SoundService _sound;

  String get _uid => _ref.read(authProvider)?.uid ?? 'guest_local';

  Future<void> _bootstrap() async {
    final progress = await _repo.load(_uid);
    final n = nextPuzzleNumber(solved: progress.solved, skipped: progress.skipped);
    state = GameViewState(
      puzzle: PuzzleState(digits: digitsOf(n), difficulty: Difficulty.easy),
      progress: progress,
    );
  }

  Future<void> reloadProgress() async {
    state = state.copyWith(loading: true);
    final progress = await _repo.load(_uid);
    final n = nextPuzzleNumber(solved: progress.solved, skipped: progress.skipped);
    state = GameViewState(
      puzzle: PuzzleState(
        digits: digitsOf(n),
        difficulty: state.puzzle.difficulty,
      ),
      progress: progress,
    );
  }

  void setDifficulty(Difficulty d) {
    state = state.copyWith(
      puzzle: PuzzleState(
        digits: state.puzzle.digits,
        difficulty: d,
      ),
      feedback: VerifyFeedback.none,
    );
  }

  void selectSlot(SlotId id) {
    state = state.copyWith(
      puzzle: state.puzzle.copyWith(selectedSlot: id),
      feedback: VerifyFeedback.none,
    );
  }

  void stamp(String op) {
    state = state.copyWith(
      puzzle: state.puzzle.stamp(op),
      feedback: VerifyFeedback.none,
    );
  }

  void drop(SlotId target, OpDrag drag, int index) {
    final next = state.puzzle.place(
      target,
      index,
      drag.op,
      from: drag.slot,
      fromIndex: drag.index,
    );
    if (identical(next, state.puzzle)) return;
    state = state.copyWith(puzzle: next, feedback: VerifyFeedback.none);
  }

  void removePlaced(SlotId slot, int index) {
    state = state.copyWith(
      puzzle: state.puzzle.removeAt(slot, index),
      feedback: VerifyFeedback.none,
    );
  }

  void backspace() {
    state = state.copyWith(
      puzzle: state.puzzle.backspace(),
      feedback: VerifyFeedback.none,
    );
  }

  void clearOps() {
    state = state.copyWith(
      puzzle: state.puzzle.clearOperators(),
      feedback: VerifyFeedback.none,
      resetAnim: state.resetAnim + 1,
    );
  }

  Future<void> verify() async {
    _sound.enabled = _ref.read(settingsProvider).soundEnabled;
    final result = evaluateExpression(
      state.puzzle.displayExpression,
      state.puzzle.difficulty,
    );

    if (!result.isOk) {
      final fb = switch (result.error) {
        'missingEquals' => VerifyFeedback.missingEquals,
        'nonIntegerDivision' => VerifyFeedback.nonIntegerDivision,
        _ => VerifyFeedback.invalid,
      };
      await _sound.playFail();
      state = state.copyWith(feedback: fb, resetAnim: state.resetAnim + 1);
      state = state.copyWith(puzzle: state.puzzle.clearOperators());
      return;
    }

    if (result.equal) {
      await _sound.playSuccess();
      final num = state.puzzle.number;
      final nextProgress = state.progress.copyWith(
        score: state.progress.score + _pointsFor(state.puzzle.difficulty),
        solved: {...state.progress.solved, num},
      );
      await _repo.save(_uid, nextProgress);
      final next = nextPuzzleNumber(
        solved: nextProgress.solved,
        skipped: nextProgress.skipped,
      );
      state = GameViewState(
        puzzle: PuzzleState(
          digits: digitsOf(next),
          difficulty: state.puzzle.difficulty,
        ),
        progress: nextProgress,
        feedback: VerifyFeedback.correct,
        resetAnim: state.resetAnim + 1,
      );
    } else {
      await _sound.playFail();
      state = state.copyWith(
        feedback: VerifyFeedback.incorrect,
        resetAnim: state.resetAnim + 1,
        puzzle: state.puzzle.clearOperators(),
      );
    }
  }

  Future<void> skip() async {
    final num = state.puzzle.number;
    final nextProgress = state.progress.copyWith(
      skipped: {...state.progress.skipped, num},
    );
    await _repo.save(_uid, nextProgress);
    final next = nextPuzzleNumber(
      solved: nextProgress.solved,
      skipped: nextProgress.skipped,
    );
    state = GameViewState(
      puzzle: PuzzleState(
        digits: digitsOf(next),
        difficulty: state.puzzle.difficulty,
      ),
      progress: nextProgress,
      resetAnim: state.resetAnim + 1,
    );
  }

  int _pointsFor(Difficulty d) => switch (d) {
        Difficulty.easy => 1,
        Difficulty.intermediate => 2,
        Difficulty.advanced => 3,
        Difficulty.hard => 5,
      };
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final s = SoundService();
  ref.onDispose(s.dispose);
  return s;
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  throw UnimplementedError('override in main');
});

final gameProvider = StateNotifierProvider<GameNotifier, GameViewState>((ref) {
  return GameNotifier(
    ref,
    ref.watch(progressRepositoryProvider),
    ref.watch(soundServiceProvider),
  );
});

/// Future usado pela tela de progresso com FutureBuilder.
final progressFutureProvider = FutureProvider<UserProgress>((ref) async {
  final uid = ref.watch(authProvider)?.uid ?? 'guest_local';
  return ref.watch(progressRepositoryProvider).load(uid);
});
