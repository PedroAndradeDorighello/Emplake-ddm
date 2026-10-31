/// Converte a expressão de UI (× ÷ √ ∛ ** ⌊⌋ ⌈⌉) em LaTeX.
String expressionToLatex(String expr) {
  var s = expr;
  s = s.replaceAll('×', r'\times ');
  s = s.replaceAll('÷', r'\div ');
  s = s.replaceAll('**', '^');
  s = s.replaceAll('⌊', r'\lfloor ');
  s = s.replaceAll('⌋', r'\rfloor ');
  s = s.replaceAll('⌈', r'\lceil ');
  s = s.replaceAll('⌉', r'\rceil ');
  s = s.replaceAll('|', r'\lvert ');
  // √( ... ) / √x  e ∛
  s = _wrapUnary(s, '√', r'\sqrt');
  s = _wrapUnary(s, '∛', r'\sqrt[3]');
  s = s.replaceAll('!', r'!');
  s = s.replaceAll('=', r' = ');
  return s;
}

String _wrapUnary(String input, String symbol, String latexCmd) {
  final out = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    if (input.startsWith(symbol, i)) {
      out.write(latexCmd);
      i += symbol.length - 1;
      final rest = input.substring(i + 1);
      if (rest.startsWith('(')) {
        final end = _matchingParen(rest);
        if (end > 0) {
          out.write('{${rest.substring(1, end)}}');
          i += end;
          continue;
        }
      }
      // próximo token curto
      final m = RegExp(r'^[\d.]+').firstMatch(rest);
      if (m != null) {
        out.write('{${m.group(0)}}');
        i += m.group(0)!.length;
      }
      continue;
    }
    out.write(input[i]);
  }
  return out.toString();
}

int _matchingParen(String s) {
  var depth = 0;
  for (var i = 0; i < s.length; i++) {
    if (s[i] == '(') depth++;
    if (s[i] == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}
