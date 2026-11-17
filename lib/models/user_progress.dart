import 'difficulty.dart';

class SavedSolution {
  const SavedSolution({
    required this.expression,
    this.difficulty = Difficulty.hard,
  });

  final String expression;
  final Difficulty difficulty;

  Map<String, dynamic> toMap() => {
        'expression': expression,
        'difficulty': difficulty.storageKey,
      };

  factory SavedSolution.fromDynamic(dynamic raw) {
    if (raw is String) {
      // Formato antigo: só a expressão.
      return SavedSolution(expression: raw);
    }
    if (raw is Map) {
      final expr = raw['expression']?.toString() ?? '';
      final key = raw['difficulty']?.toString();
      final d = Difficulty.values.where((e) => e.storageKey == key).firstOrNull ??
          Difficulty.hard;
      return SavedSolution(expression: expr, difficulty: d);
    }
    return const SavedSolution(expression: '');
  }
}

class UserProgress {
  const UserProgress({
    this.score = 0,
    this.solved = const [],
    this.skipped = const {},
    this.solutions = const {},
  });

  final int score;
  /// Ordem cronológica: primeiro resolvido → último.
  final List<int> solved;
  final Set<int> skipped;
  /// Solução salva ao acertar, chave = número do puzzle.
  final Map<int, SavedSolution> solutions;

  UserProgress copyWith({
    int? score,
    List<int>? solved,
    Set<int>? skipped,
    Map<int, SavedSolution>? solutions,
  }) {
    return UserProgress(
      score: score ?? this.score,
      solved: solved ?? this.solved,
      skipped: skipped ?? this.skipped,
      solutions: solutions ?? this.solutions,
    );
  }

  /// Acrescenta [n] no fim (mais recente). Se já existia, move para o fim.
  List<int> withSolved(int n) => [...solved.where((e) => e != n), n];

  /// Une dois progressos (útil progress local + remoto).
  UserProgress mergeWith(UserProgress other) {
    final mergedSolutions = <int, SavedSolution>{...solutions};
    for (final e in other.solutions.entries) {
      if (e.value.expression.trim().isEmpty) continue;
      mergedSolutions[e.key] = e.value;
    }
    final order = [...solved];
    for (final n in other.solved) {
      if (!order.contains(n)) order.add(n);
    }
    return UserProgress(
      score: score >= other.score ? score : other.score,
      solved: order,
      skipped: {...skipped, ...other.skipped},
      solutions: mergedSolutions,
    );
  }

  Map<String, dynamic> toMap() => {
        'score': score,
        'solved': solved,
        'skipped': skipped.toList(),
        'solutions': {
          for (final e in solutions.entries) '${e.key}': e.value.toMap(),
        },
      };

  factory UserProgress.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserProgress();
    final rawSolutions = map['solutions'];
    final solutions = <int, SavedSolution>{};
    if (rawSolutions is Map) {
      for (final e in rawSolutions.entries) {
        final n = int.tryParse(e.key.toString());
        if (n == null) continue;
        final s = SavedSolution.fromDynamic(e.value);
        if (s.expression.isNotEmpty) solutions[n] = s;
      }
    }
    // Lista preserva ordem; Set antigo no JSON vira lista na ordem do encode.
    final solvedList = <int>[
      ...((map['solved'] as List?)?.map((e) => (e as num).toInt()) ?? []),
    ];
    return UserProgress(
      score: (map['score'] as num?)?.toInt() ?? 0,
      solved: solvedList,
      skipped: {
        ...((map['skipped'] as List?)?.map((e) => (e as num).toInt()) ?? []),
      },
      solutions: solutions,
    );
  }
}
