import 'package:emplake/models/difficulty.dart';
import 'package:emplake/models/puzzle_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PuzzleState board(String mid) => PuzzleState(
        digits: const [1, 2, 3, 4],
        difficulty: Difficulty.easy,
        mids: [mid, '', ''],
      );

  test('inserts to the left of an existing sign', () {
    final next = board('+').place(SlotId.mid0, 0, '-');
    expect(next.mids[0], '-+');
  });

  test('moves a sign to the left of its neighbor', () {
    final next = board('+-').place(
      SlotId.mid0,
      0,
      '-',
      from: SlotId.mid0,
      fromIndex: 1,
    );
    expect(next.mids[0], '-+');
  });

  test('dropping on the same spot does not shuffle', () {
    final start = board('+-');
    final next = start.place(
      SlotId.mid0,
      2,
      '-',
      from: SlotId.mid0,
      fromIndex: 1,
    );
    expect(identical(next, start), isTrue);
  });
}
