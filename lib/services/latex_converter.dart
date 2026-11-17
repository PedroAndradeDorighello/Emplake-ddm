/// Converte a expressão de UI (× ÷ √ ∛ ** ⌊⌋ ⌈⌉ |) em LaTeX.
String expressionToLatex(String expr) {
  var s = expr;
  // ** antes das raízes, para `3**√9` virar `3^{√9}` e depois `3^{\sqrt{9}}`.
  s = _bracePowers(s);
  s = _wrapUnary(s, '√', r'\sqrt');
  s = _wrapUnary(s, '∛', r'\sqrt[3]');
  s = s.replaceAll('×', r'\times ');
  s = s.replaceAll('÷', r'\div ');
  s = s.replaceAll('⌊', r'\lfloor ');
  s = s.replaceAll('⌋', r'\rfloor ');
  s = s.replaceAll('⌈', r'\lceil ');
  s = s.replaceAll('⌉', r'\rceil ');
  s = _wrapAbs(s);
  s = s.replaceAll('=', r' = ');
  return s;
}

/// `a**b` / `a**(…)` → `a^{b}` (expoente multi-dígito precisa de chaves).
String _bracePowers(String input) {
  final out = StringBuffer();
  var i = 0;
  while (i < input.length) {
    if (input.startsWith('**', i)) {
      out.write('^{');
      i += 2;
      final start = i;
      if (i < input.length && input[i] == '(') {
        final end = _matchingParen(input.substring(i));
        if (end > 0) {
          out
            ..write(input.substring(i + 1, i + end))
            ..write('}');
          i += end + 1;
          continue;
        }
      }
      while (i < input.length &&
          (input.startsWith('√', i) ||
              input.startsWith('∛', i) ||
              input[i] == '-')) {
        i += input.startsWith('∛', i) ? '∛'.length : 1;
      }
      if (i < input.length && input[i] == '(') {
        final end = _matchingParen(input.substring(i));
        if (end > 0) {
          out
            ..write(input.substring(start, i + end + 1))
            ..write('}');
          i += end + 1;
          continue;
        }
      }
      final m = RegExp(r'^[\d.]+').firstMatch(input.substring(i));
      if (m != null) {
        out
          ..write(input.substring(start, i + m.group(0)!.length))
          ..write('}');
        i += m.group(0)!.length;
        continue;
      }
      out.write('}');
      continue;
    }
    out.write(input[i]);
    i++;
  }
  return out.toString();
}

String _wrapAbs(String input) {
  final out = StringBuffer();
  var open = true;
  for (var i = 0; i < input.length; i++) {
    if (input[i] == '|') {
      out.write(open ? r'\left\lvert ' : r'\right\rvert ');
      open = !open;
    } else {
      out.write(input[i]);
    }
  }
  return out.toString();
}

String _wrapUnary(String input, String symbol, String latexCmd) {
  final out = StringBuffer();
  var i = 0;
  while (i < input.length) {
    if (input.startsWith(symbol, i)) {
      out.write(latexCmd);
      i += symbol.length;
      if (i < input.length && input[i] == '(') {
        final end = _matchingParen(input.substring(i));
        if (end > 0) {
          out.write('{${input.substring(i + 1, i + end)}}');
          i += end + 1;
          continue;
        }
      }
      final m = RegExp(r'^[\d.]+').firstMatch(input.substring(i));
      if (m != null) {
        out.write('{${m.group(0)}}');
        i += m.group(0)!.length;
      }
      continue;
    }
    out.write(input[i]);
    i++;
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
