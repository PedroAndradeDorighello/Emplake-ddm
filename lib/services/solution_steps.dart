import 'dart:math' as math;

import '../models/difficulty.dart';
import 'expression_evaluator.dart';

/// Etapas LaTeX da resolução, até os dois lados virarem o mesmo número.
List<String> solutionLatexSteps(String raw, Difficulty difficulty) {
  final result = evaluateExpression(raw, difficulty);
  if (!result.isOk || !result.equal) return const [];

  final norm = raw
      .replaceAll(' ', '')
      .replaceAll('×', '*')
      .replaceAll('÷', '/')
      .replaceAll('√', 'sqrt')
      .replaceAll('∛', 'cbrt')
      .replaceAll('**', '^')
      .replaceAll('⌊', 'floor(')
      .replaceAll('⌋', ')')
      .replaceAll('⌈', 'ceil(')
      .replaceAll('⌉', ')');
  final parts = norm.split('=');
  if (parts.length != 2) return const [];

  final flags = _Flags(allowNonIntDiv: difficulty.allowsNonIntegerDivision);
  var left = _parse(parts[0], flags);
  var right = _parse(parts[1], flags);
  // Não inclui a equação montada (já está na prévia LaTeX).
  final steps = <String>[];

  // ponytail: no máx. 40 passos; evita loop se algum nó não reduzir
  for (var i = 0; i < 40; i++) {
    if (left.isLit && right.isLit) {
      final line = '${left.latex} = ${right.latex}';
      if (steps.isEmpty || steps.last != line) steps.add(line);
      break;
    }
    if (!left.isLit) {
      left = left.step(flags);
    } else {
      right = right.step(flags);
    }
    final line = '${left.latex} = ${right.latex}';
    if (steps.isEmpty || steps.last != line) steps.add(line);
  }
  return steps;
}

class _Flags {
  _Flags({required this.allowNonIntDiv});
  final bool allowNonIntDiv;
}

abstract class _Node {
  bool get isLit;
  double get value;
  String get latex;
  _Node step(_Flags flags);
}

class _Lit extends _Node {
  _Lit(this.value);
  @override
  final double value;
  @override
  bool get isLit => true;
  @override
  String get latex => _fmt(value);
  @override
  _Node step(_Flags flags) => this;
}

class _Unary extends _Node {
  _Unary(this.op, this.child);
  final String op; // -, sqrt, cbrt, floor, ceil, abs, !
  final _Node child;
  @override
  bool get isLit => false;
  @override
  double get value => 0;
  @override
  String get latex => switch (op) {
        '-' => '-${_parenIfNeeded(child)}',
        'sqrt' => '\\sqrt{${child.latex}}',
        'cbrt' => '\\sqrt[3]{${child.latex}}',
        'floor' => '\\lfloor ${child.latex}\\rfloor',
        'ceil' => '\\lceil ${child.latex}\\rceil',
        'abs' => '\\left\\lvert ${child.latex}\\right\\rvert',
        '!' => '${_parenIfNeeded(child)}!',
        _ => child.latex,
      };

  @override
  _Node step(_Flags flags) {
    if (!child.isLit) return _Unary(op, child.step(flags));
    final v = child.value;
    final out = switch (op) {
      '-' => -v,
      'sqrt' => math.sqrt(v),
      'cbrt' => v == 0 ? 0.0 : math.pow(v.abs(), 1 / 3).toDouble() * (v < 0 ? -1 : 1),
      'floor' => v.floorToDouble(),
      'ceil' => v.ceilToDouble(),
      'abs' => v.abs(),
      '!' => _factorial(v),
      _ => v,
    };
    return _Lit(out);
  }
}

class _Binary extends _Node {
  _Binary(this.op, this.left, this.right);
  final String op; // + - * / ^
  final _Node left;
  final _Node right;
  @override
  bool get isLit => false;
  @override
  double get value => 0;
  @override
  String get latex {
    final a = left.latex;
    final b = right.latex;
    return switch (op) {
      '+' => '$a + $b',
      '-' => '$a - $b',
      '*' => '$a \\times $b',
      '/' => '$a \\div $b',
      '^' => '$a^{$b}',
      _ => '$a $op $b',
    };
  }

  @override
  _Node step(_Flags flags) {
    if (!left.isLit) return _Binary(op, left.step(flags), right);
    if (!right.isLit) return _Binary(op, left, right.step(flags));
    final a = left.value;
    final b = right.value;
    final out = switch (op) {
      '+' => a + b,
      '-' => a - b,
      '*' => a * b,
      '/' => a / b,
      '^' => math.pow(a, b).toDouble(),
      _ => a,
    };
    return _Lit(out);
  }
}

String _parenIfNeeded(_Node n) {
  if (n is _Lit || (n is _Unary && n.op != '-')) return n.latex;
  return '(${n.latex})';
}

String _fmt(double v) {
  if (!v.isFinite) return '?';
  if ((v - v.roundToDouble()).abs() < 1e-9) return '${v.round()}';
  var s = v.toStringAsFixed(6);
  s = s.replaceFirst(RegExp(r'\.?0+$'), '');
  return s;
}

double _factorial(double x) {
  final n = x.round();
  var r = 1.0;
  for (var i = 2; i <= n; i++) {
    r *= i;
  }
  return r;
}

// --- parser (mesma precedência do avaliador) ---

_Node _parse(String input, _Flags flags) {
  final p = _P(_tokenize(input), flags);
  final n = p.expr();
  if (p.i != p.tokens.length) throw StateError('trailing');
  return n;
}

class _P {
  _P(this.tokens, this.flags) : i = 0;
  final List<_T> tokens;
  final _Flags flags;
  int i;

  _T? get _peek => i < tokens.length ? tokens[i] : null;

  bool _match(Set<String> kinds) {
    final t = _peek;
    if (t != null && kinds.contains(t.k)) {
      i++;
      return true;
    }
    return false;
  }

  _Node expr() {
    var n = term();
    while (_match({'+', '-'})) {
      final op = tokens[i - 1].k;
      n = _Binary(op, n, term());
    }
    return n;
  }

  _Node term() {
    var n = power();
    while (_match({'*', '/'})) {
      final op = tokens[i - 1].k;
      n = _Binary(op, n, power());
    }
    return n;
  }

  _Node power() {
    var n = unary();
    if (_match({'^'})) {
      n = _Binary('^', n, power());
    }
    while (_match({'!'})) {
      n = _Unary('!', n);
    }
    return n;
  }

  _Node unary() {
    if (_match({'+'})) return unary();
    if (_match({'-'})) return _Unary('-', unary());
    if (_match({'sqrt'})) return _Unary('sqrt', unary());
    if (_match({'cbrt'})) return _Unary('cbrt', unary());
    if (_match({'floor'})) return _Unary('floor', _callOrUnary());
    if (_match({'ceil'})) return _Unary('ceil', _callOrUnary());
    if (_match({'|'})) {
      final inner = expr();
      if (!_match({'|'})) throw StateError('abs');
      return _Unary('abs', inner);
    }
    return primary();
  }

  _Node _callOrUnary() {
    if (_peek?.k == '(') {
      i++;
      final n = expr();
      if (!_match({')'})) throw StateError(')');
      return n;
    }
    return unary();
  }

  _Node primary() {
    final t = _peek;
    if (t?.k == 'num') {
      i++;
      return _Lit(t!.v!);
    }
    if (_match({'('})) {
      final n = expr();
      if (!_match({')'})) throw StateError(')');
      return n;
    }
    throw StateError('primary');
  }
}

class _T {
  _T(this.k, [this.v]);
  final String k;
  final double? v;
}

List<_T> _tokenize(String input) {
  final out = <_T>[];
  var i = 0;
  while (i < input.length) {
    final c = input[i];
    if ('+-*/^()!|'.contains(c)) {
      out.add(_T(c));
      i++;
    } else if (input.startsWith('sqrt', i)) {
      out.add(_T('sqrt'));
      i += 4;
    } else if (input.startsWith('cbrt', i)) {
      out.add(_T('cbrt'));
      i += 4;
    } else if (input.startsWith('floor', i)) {
      out.add(_T('floor'));
      i += 5;
    } else if (input.startsWith('ceil', i)) {
      out.add(_T('ceil'));
      i += 4;
    } else if ((c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) || c == '.') {
      final start = i;
      i++;
      while (i < input.length &&
          ((input.codeUnitAt(i) >= 48 && input.codeUnitAt(i) <= 57) ||
              input[i] == '.')) {
        i++;
      }
      out.add(_T('num', double.parse(input.substring(start, i))));
    } else {
      throw StateError('tok');
    }
  }
  return out;
}
