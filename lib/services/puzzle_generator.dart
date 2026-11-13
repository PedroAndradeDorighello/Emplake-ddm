import 'dart:math';

import 'hard_solvable_numbers.dart';

/// Gera número de 4 dígitos ainda não resolvido/pulado.
/// Em todos os níveis, só sorteia números com solução no conjunto do Difícil.
int nextPuzzleNumber({
  required Set<int> solved,
  required Set<int> skipped,
  Random? random,
}) {
  final rng = random ?? Random();
  final blocked = {...solved, ...skipped};
  bool allowed(int n) => isHardSolvable(n) && !blocked.contains(n);

  // ponytail: O(tentativas); espaço útil ~4377
  for (var attempt = 0; attempt < 8000; attempt++) {
    final n = 1000 + rng.nextInt(9000);
    if (allowed(n)) return n;
  }
  for (final n in hardSolvableNumbers) {
    if (!solved.contains(n)) return n;
  }
  final pool = hardSolvableNumbers.difference(solved).toList();
  if (pool.isNotEmpty) return pool[rng.nextInt(pool.length)];
  return hardSolvableNumbers.first;
}

List<int> digitsOf(int n) {
  final s = n.toString().padLeft(4, '0');
  return [for (var i = 0; i < 4; i++) int.parse(s[i])];
}
