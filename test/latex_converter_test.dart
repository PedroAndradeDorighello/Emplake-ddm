import 'package:emplake/services/latex_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('** braces multi-digit exponents', () {
    expect(expressionToLatex('3**12'), '3^{12}');
    expect(expressionToLatex('3**(1+2)'), '3^{1+2}');
    expect(expressionToLatex('√(8+1)=3**1'), r'\sqrt{8+1} = 3^{1}');
  });

  test('abs uses left/right lvert', () {
    final s = expressionToLatex('|3-5|');
    expect(s, contains(r'\left\lvert'));
    expect(s, contains(r'\right\rvert'));
  });
}
