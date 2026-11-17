import 'package:emplake/models/difficulty.dart';
import 'package:emplake/services/solution_steps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('steps reduce 1+2*3=7 to equal literals', () {
    final steps = solutionLatexSteps('1+2×3=7', Difficulty.hard);
    expect(steps, isNotEmpty);
    expect(steps.first, isNot(equals(r'1 + 2 \times 3 = 7')));
    expect(steps.last, '7 = 7');
  });

  test('sqrt steps skip the original equation', () {
    final steps = solutionLatexSteps('√(8+1)=3**1', Difficulty.easy);
    expect(steps, isNotEmpty);
    expect(steps.first, isNot(contains(r'\sqrt{8+1}')));
    expect(steps.last, '3 = 3');
  });
}
