enum Difficulty {
  easy,
  intermediate,
  advanced,
  hard;

  String get storageKey => name;
}

extension DifficultyOps on Difficulty {
  /// Operadores disponíveis por nível (símbolos de UI / stamp).
  List<String> get operators {
    const base = ['+', '-', '×', '÷', '(', ')', '|', '='];
    return switch (this) {
      Difficulty.easy => [
          ...base,
          '√',
          '∛',
          '!',
          '**',
          '⌊',
          '⌋',
          '⌈',
          '⌉',
        ],
      Difficulty.intermediate => [...base, '√', '∛', '!', '**'],
      Difficulty.advanced => [...base, '√', '!'],
      Difficulty.hard => base,
    };
  }

  bool get allowsNonIntegerDivision => this == Difficulty.easy;
}
