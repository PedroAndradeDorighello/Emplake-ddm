import 'package:emplake/models/difficulty.dart';
import 'package:emplake/services/expression_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('3-4=5-6 is true', () {
    final r = evaluateExpression('3-4=5-6', Difficulty.hard);
    expect(r.isOk, true);
    expect(r.equal, true);
  });

  test('non-integer division blocked outside easy', () {
    final r = evaluateExpression('5÷2=2+0.5', Difficulty.hard);
    expect(r.error, 'nonIntegerDivision');
  });

  test('easy allows non-integer division', () {
    final r = evaluateExpression('5÷2=2.5', Difficulty.easy);
    expect(r.isOk, true);
    expect(r.equal, true);
  });

  test('sqrt and pow', () {
    final r = evaluateExpression('√(8+1)=3**1', Difficulty.easy);
    expect(r.isOk, true);
    expect(r.equal, true);
  });

  test('precedence: * over +', () {
    final r = evaluateExpression('1+2×3=7', Difficulty.hard);
    expect(r.isOk, true);
    expect(r.equal, true);
  });

  test('precedence: factorial binds tighter than *', () {
    final r = evaluateExpression('2×3!=12', Difficulty.advanced);
    expect(r.isOk, true);
    expect(r.equal, true);
  });

  test('unary minus and double minus', () {
    expect(evaluateExpression('-2+2=0', Difficulty.hard).equal, true);
    expect(evaluateExpression('--2+0!=3', Difficulty.advanced).equal, true);
  });

  test('sqrt applies only to following number', () {
    // (√8)! ≈ 1? No — professor: √8! + 0 = 1 means (√8)! 
    // √9+7 = 3+7 = 10, not √16
    final r = evaluateExpression('√9+7=10', Difficulty.advanced);
    expect(r.isOk, true);
    expect(r.equal, true);
  });
}
