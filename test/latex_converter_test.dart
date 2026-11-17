import 'package:emplake/services/latex_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('** braces multi-digit exponents', () {
    expect(expressionToLatex('3**12'), '3^{12}');
    expect(expressionToLatex('3**(1+2)'), '3^{1+2}');
    expect(expressionToLatex('√(8+1)=3**1'), r'\sqrt{8+1} = 3^{1}');
  });

  test('abs pairs and unpaired bar', () {
    final pair = expressionToLatex('|3-5|');
    expect(pair, contains(r'\left\lvert'));
    expect(pair, contains(r'\right\rvert'));
    expect(expressionToLatex('|'), r'\lvert ');
    expect(expressionToLatex('|3'), r'\lvert 3');
  });

  test('stray stars from incomplete ** stay valid latex', () {
    final s = expressionToLatex('3***2');
    expect(s, isNot(contains('*')));
    expect(s, contains(r'\square'));
    expect(s, contains(r'\times'));
  });

  test('two powers', () {
    expect(expressionToLatex('2**3**2'), r'2^{3}^{2}');
  });
}
