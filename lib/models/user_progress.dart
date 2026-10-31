class UserProgress {
  const UserProgress({
    this.score = 0,
    this.solved = const {},
    this.skipped = const {},
  });

  final int score;
  final Set<int> solved;
  final Set<int> skipped;

  UserProgress copyWith({
    int? score,
    Set<int>? solved,
    Set<int>? skipped,
  }) {
    return UserProgress(
      score: score ?? this.score,
      solved: solved ?? this.solved,
      skipped: skipped ?? this.skipped,
    );
  }

  Map<String, dynamic> toMap() => {
        'score': score,
        'solved': solved.toList(),
        'skipped': skipped.toList(),
      };

  factory UserProgress.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserProgress();
    return UserProgress(
      score: (map['score'] as num?)?.toInt() ?? 0,
      solved: {...((map['solved'] as List?)?.map((e) => (e as num).toInt()) ?? [])},
      skipped: {...((map['skipped'] as List?)?.map((e) => (e as num).toInt()) ?? [])},
    );
  }
}
