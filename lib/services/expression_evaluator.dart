import 'dart:math' as math;

import '../models/difficulty.dart';

class EvalResult {
  const EvalResult.ok(this.left, this.right) : error = null;
  const EvalResult.err(this.error)
      : left = null,
        right = null;

  final double? left;
  final double? right;
  final String? error;

  bool get isOk => error == null;

  bool get equal {
    if (left == null || right == null) return false;
    return (left! - right!).abs() < 1e-9;
  }
}

EvalResult evaluateExpression(String raw, Difficulty difficulty) {
  final expr = _normalize(raw);
  final parts = expr.split('=');
  if (parts.length != 2) {
    return const EvalResult.err('missingEquals');
  }
  if (parts[0].isEmpty || parts[1].isEmpty) {
    return const EvalResult.err('invalidExpression');
  }

  try {
    final flags = _EvalFlags(allowNonIntDiv: difficulty.allowsNonIntegerDivision);
    final left = _Parser(parts[0], flags).parse();
    final right = _Parser(parts[1], flags).parse();
    return EvalResult.ok(left, right);
  } on _EvalException catch (e) {
    return EvalResult.err(e.code);
  } catch (_) {
    return const EvalResult.err('invalidExpression');
  }
}

String _normalize(String s) {
  return s
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
}

class _EvalFlags {
  _EvalFlags({required this.allowNonIntDiv});
  final bool allowNonIntDiv;
}

class _EvalException implements Exception {
  _EvalException(this.code);
  final String code;
}

class _Parser {
  _Parser(String input, this.flags)
      : _tokens = _tokenize(input),
        _i = 0;

  final _EvalFlags flags;
  final List<_Tok> _tokens;
  int _i;

  double parse() {
    final v = _expr();
    if (_i != _tokens.length) throw _EvalException('invalidExpression');
    return v;
  }

  double _expr() {
    var v = _term();
    while (_match(const [_Kind.plus, _Kind.minus])) {
      final op = _tokens[_i - 1].kind;
      final r = _term();
      v = op == _Kind.plus ? v + r : v - r;
    }
    return v;
  }

  double _term() {
    var v = _power();
    while (_match(const [_Kind.mul, _Kind.div])) {
      final op = _tokens[_i - 1].kind;
      final r = _power();
      if (op == _Kind.mul) {
        v *= r;
      } else {
        if (r == 0) throw _EvalException('invalidExpression');
        final q = v / r;
        if (!flags.allowNonIntDiv && (q - q.roundToDouble()).abs() > 1e-9) {
          throw _EvalException('nonIntegerDivision');
        }
        v = q;
      }
    }
    return v;
  }

  double _power() {
    var v = _unary();
    if (_match(const [_Kind.pow])) {
      final exp = _power();
      v = _pow(v, exp);
    }
    while (_match(const [_Kind.fact])) {
      v = _factorial(v);
    }
    return v;
  }

  double _unary() {
    if (_match(const [_Kind.plus])) return _unary();
    if (_match(const [_Kind.minus])) return -_unary();
    if (_match(const [_Kind.sqrt])) return _sqrt(_unary());
    if (_match(const [_Kind.cbrt])) return _cbrt(_unary());
    if (_match(const [_Kind.floor])) return _callOrUnary((x) => x.floorToDouble());
    if (_match(const [_Kind.ceil])) return _callOrUnary((x) => x.ceilToDouble());
    if (_match(const [_Kind.absBar])) {
      final v = _expr();
      _expect(_Kind.absBar);
      return v.abs();
    }
    return _primary();
  }

  double _callOrUnary(double Function(double) f) {
    if (_peek()?.kind == _Kind.lparen) {
      _i++;
      final v = _expr();
      _expect(_Kind.rparen);
      return f(v);
    }
    return f(_unary());
  }

  double _primary() {
    if (_match(const [_Kind.number])) {
      return _tokens[_i - 1].value!;
    }
    if (_match(const [_Kind.lparen])) {
      final v = _expr();
      _expect(_Kind.rparen);
      return v;
    }
    throw _EvalException('invalidExpression');
  }

  bool _match(List<_Kind> kinds) {
    final t = _peek();
    if (t != null && kinds.contains(t.kind)) {
      _i++;
      return true;
    }
    return false;
  }

  _Tok? _peek() => _i < _tokens.length ? _tokens[_i] : null;

  void _expect(_Kind k) {
    if (!_match([k])) throw _EvalException('invalidExpression');
  }
}

double _sqrt(double x) {
  if (x < 0) throw _EvalException('invalidExpression');
  return math.sqrt(x);
}

double _cbrt(double x) {
  if (x == 0) return 0;
  final r = math.pow(x.abs(), 1 / 3).toDouble();
  return x < 0 ? -r : r;
}

double _pow(double base, double exp) {
  if (base == 0 && exp <= 0) throw _EvalException('invalidExpression');
  if ((exp - exp.roundToDouble()).abs() < 1e-12) {
    final n = exp.round();
    var r = 1.0;
    for (var i = 0; i < n.abs(); i++) {
      r *= base;
    }
    return n < 0 ? 1 / r : r;
  }
  if (base < 0) throw _EvalException('invalidExpression');
  return math.pow(base, exp).toDouble();
}

double _factorial(double x) {
  if (x < 0 || (x - x.roundToDouble()).abs() > 1e-9) {
    throw _EvalException('invalidExpression');
  }
  final n = x.round();
  if (n > 20) throw _EvalException('invalidExpression');
  var r = 1.0;
  for (var i = 2; i <= n; i++) {
    r *= i;
  }
  return r;
}

enum _Kind {
  number,
  plus,
  minus,
  mul,
  div,
  pow,
  lparen,
  rparen,
  fact,
  sqrt,
  cbrt,
  floor,
  ceil,
  absBar,
}

class _Tok {
  _Tok(this.kind, [this.value]);
  final _Kind kind;
  final double? value;
}

List<_Tok> _tokenize(String input) {
  final out = <_Tok>[];
  var i = 0;
  while (i < input.length) {
    final c = input[i];
    if (c == '+') {
      out.add(_Tok(_Kind.plus));
      i++;
    } else if (c == '-') {
      out.add(_Tok(_Kind.minus));
      i++;
    } else if (c == '*') {
      out.add(_Tok(_Kind.mul));
      i++;
    } else if (c == '/') {
      out.add(_Tok(_Kind.div));
      i++;
    } else if (c == '^') {
      out.add(_Tok(_Kind.pow));
      i++;
    } else if (c == '(') {
      out.add(_Tok(_Kind.lparen));
      i++;
    } else if (c == ')') {
      out.add(_Tok(_Kind.rparen));
      i++;
    } else if (c == '!') {
      out.add(_Tok(_Kind.fact));
      i++;
    } else if (c == '|') {
      out.add(_Tok(_Kind.absBar));
      i++;
    } else if (input.startsWith('sqrt', i)) {
      out.add(_Tok(_Kind.sqrt));
      i += 4;
    } else if (input.startsWith('cbrt', i)) {
      out.add(_Tok(_Kind.cbrt));
      i += 4;
    } else if (input.startsWith('floor', i)) {
      out.add(_Tok(_Kind.floor));
      i += 5;
    } else if (input.startsWith('ceil', i)) {
      out.add(_Tok(_Kind.ceil));
      i += 4;
    } else if (_isDigit(c) || c == '.') {
      final start = i;
      i++;
      while (i < input.length && (_isDigit(input[i]) || input[i] == '.')) {
        i++;
      }
      out.add(_Tok(_Kind.number, double.parse(input.substring(start, i))));
    } else {
      throw _EvalException('invalidExpression');
    }
  }
  return out;
}

bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
