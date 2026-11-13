import 'dart:math';

import '../models/difficulty.dart';
import 'solvable_by_difficulty.dart';

/// Gera número de 4 dígitos ainda não resolvido/pulado, solúvel no nível.
int nextPuzzleNumber({
  required Set<int> solved,
  required Set<int> skipped,
  required Difficulty difficulty,
  Random? random,
}) {
  final rng = random ?? Random();
  final pool = solvableNumbersFor(difficulty);
  final blocked = {...solved, ...skipped};
  bool allowed(int n) => pool.contains(n) && !blocked.contains(n);

  // ponytail: O(tentativas); pools ~4k–9k
  for (var attempt = 0; attempt < 8000; attempt++) {
    final n = 1000 + rng.nextInt(9000);
    if (allowed(n)) return n;
  }
  final available = pool.difference(blocked).toList();
  if (available.isNotEmpty) return available[rng.nextInt(available.length)];
  final unsolved = pool.difference(solved).toList();
  if (unsolved.isNotEmpty) return unsolved[rng.nextInt(unsolved.length)];
  return pool.first;
}

List<int> digitsOf(int n) {
  final s = n.toString().padLeft(4, '0');
  return [for (var i = 0; i < 4; i++) int.parse(s[i])];
}
