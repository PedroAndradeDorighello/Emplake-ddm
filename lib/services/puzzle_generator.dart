import 'dart:math';

/// Gera número de 4 dígitos ainda não resolvido/pulado.
int nextPuzzleNumber({
  required Set<int> solved,
  required Set<int> skipped,
  Random? random,
}) {
  final rng = random ?? Random();
  final blocked = {...solved, ...skipped};
  // ponytail: O(tentativas) — espaço 9000; se esgotar, reutiliza skipped
  for (var attempt = 0; attempt < 5000; attempt++) {
    final n = 1000 + rng.nextInt(9000);
    if (!blocked.contains(n)) return n;
  }
  for (var n = 1000; n <= 9999; n++) {
    if (!solved.contains(n)) return n;
  }
  return 1000 + rng.nextInt(9000);
}

List<int> digitsOf(int n) {
  final s = n.toString().padLeft(4, '0');
  return [for (var i = 0; i < 4; i++) int.parse(s[i])];
}
