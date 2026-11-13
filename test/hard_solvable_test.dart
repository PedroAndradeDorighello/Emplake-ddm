import 'package:emplake/models/difficulty.dart';
import 'package:emplake/services/puzzle_generator.dart';
import 'package:emplake/services/solvable_by_difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('7464 is not hard-solvable', () {
    expect(isSolvableFor(7464, Difficulty.hard), isFalse);
  });

  test('each difficulty draws only from its solvable set', () {
    for (final d in Difficulty.values) {
      for (var i = 0; i < 20; i++) {
        final n = nextPuzzleNumber(
          solved: {},
          skipped: {},
          difficulty: d,
        );
        expect(isSolvableFor(n, d), isTrue, reason: '$d → $n');
      }
    }
  });

  test('hard ⊂ advanced ⊂ intermediate ⊂ easy', () {
    expect(hardSolvableNumbers.every(advancedSolvableNumbers.contains), isTrue);
    expect(
      advancedSolvableNumbers.every(intermediateSolvableNumbers.contains),
      isTrue,
    );
    expect(
      intermediateSolvableNumbers.every(easySolvableNumbers.contains),
      isTrue,
    );
  });
}
