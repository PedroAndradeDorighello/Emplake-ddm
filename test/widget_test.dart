import 'package:emplake/models/difficulty.dart';
import 'package:emplake/services/expression_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classic emplake equality', () {
    final r = evaluateExpression('3-4=5-6', Difficulty.hard);
    expect(r.equal, isTrue);
  });
}
