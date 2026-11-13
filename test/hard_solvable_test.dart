import 'package:emplake/models/difficulty.dart';
import 'package:emplake/services/hard_solvable_numbers.dart';
import 'package:emplake/services/puzzle_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('7464 is not hard-solvable', () {
    expect(isHardSolvable(7464), isFalse);
  });

  test('every difficulty draws only from the solvable set', () {
    for (final _ in Difficulty.values) {
      for (var i = 0; i < 20; i++) {
        final n = nextPuzzleNumber(solved: {}, skipped: {});
        expect(isHardSolvable(n), isTrue, reason: '$n');
      }
    }
  });
}
