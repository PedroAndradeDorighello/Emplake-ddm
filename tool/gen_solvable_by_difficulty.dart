import 'dart:io';
import 'dart:math' as math;

/// Gera lib/services/solvable_by_difficulty.dart com um conjunto por nível.
void main() {
  final hard = _allSolvable(_Mode.hard);
  stdout.writeln('hard=${hard.length}');
  final advanced = _allSolvable(_Mode.advanced);
  stdout.writeln('advanced=${advanced.length}');
  final intermediate = _allSolvable(_Mode.intermediate);
  stdout.writeln('intermediate=${intermediate.length}');
  final easy = _allSolvable(_Mode.easy);
  stdout.writeln('easy=${easy.length}');

  final path = 'lib/services/solvable_by_difficulty.dart';
  final body = StringBuffer()
    ..writeln("import '../models/difficulty.dart';")
    ..writeln()
    ..writeln(
      '/// Números 1000–9999 com solução no nível. Gerado por tool/gen_solvable_by_difficulty.dart.',
    )
    ..writeln(_setLiteral('easySolvableNumbers', easy))
    ..writeln(_setLiteral('intermediateSolvableNumbers', intermediate))
    ..writeln(_setLiteral('advancedSolvableNumbers', advanced))
    ..writeln(_setLiteral('hardSolvableNumbers', hard))
    ..writeln()
    ..writeln('Set<int> solvableNumbersFor(Difficulty d) => switch (d) {')
    ..writeln('      Difficulty.easy => easySolvableNumbers,')
    ..writeln('      Difficulty.intermediate => intermediateSolvableNumbers,')
    ..writeln('      Difficulty.advanced => advancedSolvableNumbers,')
    ..writeln('      Difficulty.hard => hardSolvableNumbers,')
    ..writeln('    };')
    ..writeln()
    ..writeln(
      'bool isSolvableFor(int n, Difficulty d) => solvableNumbersFor(d).contains(n);',
    );

  File(path).writeAsStringSync(body.toString());
  stdout.writeln(
    'wrote $path '
    'easy=${easy.length} mid=${intermediate.length} '
    'adv=${advanced.length} hard=${hard.length} '
    '7464 hard=${hard.contains(7464)} easy=${easy.contains(7464)}',
  );
}

String _setLiteral(String name, Set<int> values) {
  final sorted = values.toList()..sort();
  return 'const $name = <int>{\n'
      '${sorted.map((n) => '  $n,').join('\n')}\n'
      '};\n';
}

Set<int> _allSolvable(_Mode mode) {
  _memo.clear();
  final ok = <int>{};
  for (var n = 1000; n <= 9999; n++) {
    if (_solvable(n, mode)) ok.add(n);
  }
  return ok;
}

bool _solvable(int n, _Mode mode) {
  final d = [
    n ~/ 1000,
    (n ~/ 100) % 10,
    (n ~/ 10) % 10,
    n % 10,
  ];
  for (var split = 1; split <= 3; split++) {
    final left = _values(d.sublist(0, split), mode);
    final right = _values(d.sublist(split), mode);
    for (final a in left) {
      for (final b in right) {
        if ((a - b).abs() < 1e-9) return true;
      }
    }
  }
  return false;
}

Set<double> _values(List<int> digits, _Mode mode) {
  final key = '${mode.name}:${digits.join()}';
  return _memo.putIfAbsent(key, () {
    final out = <double>{};
    out.add(double.parse(digits.join()));
    if (digits.length > 1) {
      for (var i = 1; i < digits.length; i++) {
        final L = _values(digits.sublist(0, i), mode);
        final R = _values(digits.sublist(i), mode);
        for (final a in L) {
          for (final b in R) {
            out.add(a + b);
            out.add(a - b);
            out.add(a * b);
            if (b.abs() > 1e-12) {
              final q = a / b;
              if (mode.nonIntDiv || (q - q.roundToDouble()).abs() < 1e-9) {
                out.add(mode.nonIntDiv ? q : q.roundToDouble());
              }
            }
            if (mode.pow) {
              final p = _safePow(a, b);
              if (p != null) out.add(p);
            }
          }
        }
      }
    }
    // Uma passada de unários (como gen_hard_solvable) — sem fechamento
    // iterativo com floor/ceil, que explode o conjunto.
    final base = out.toList();
    for (final v in base) {
      out.add(-v);
      out.add(v.abs());
      if (mode.sqrt && v >= 0) {
        final s = math.sqrt(v);
        if (s.isFinite) out.add(s);
      }
      if (mode.cbrt) {
        out.add(
          v == 0
              ? 0
              : math.pow(v.abs(), 1 / 3).toDouble() * (v < 0 ? -1 : 1),
        );
      }
      if (mode.fact && _isNonNegInt(v) && v <= 12) {
        out.add(_factorial(v.round()));
      }
      if (mode.floorCeil) {
        out.add(v.floorToDouble());
        out.add(v.ceilToDouble());
      }
    }
    return out;
  });
}

double? _safePow(double base, double exp) {
  if (!_isInt(exp)) return null;
  final e = exp.round();
  if (e.abs() > 8) return null;
  if (base == 0 && e <= 0) return null;
  if (base < 0 && e < 0) return null;
  if (base.abs() > 1e6 && e.abs() > 3) return null;
  var r = 1.0;
  for (var i = 0; i < e.abs(); i++) {
    r *= base;
    if (!r.isFinite || r.abs() > 1e12) return null;
  }
  return e < 0 ? 1 / r : r;
}

bool _isInt(double x) => (x - x.roundToDouble()).abs() < 1e-9;

bool _isNonNegInt(double x) => x >= -1e-9 && _isInt(x);

double _factorial(int n) {
  var r = 1.0;
  for (var i = 2; i <= n; i++) {
    r *= i;
  }
  return r;
}

enum _Mode {
  hard(
    nonIntDiv: false,
    sqrt: false,
    cbrt: false,
    fact: false,
    pow: false,
    floorCeil: false,
  ),
  advanced(
    nonIntDiv: false,
    sqrt: true,
    cbrt: false,
    fact: true,
    pow: false,
    floorCeil: false,
  ),
  intermediate(
    nonIntDiv: false,
    sqrt: true,
    cbrt: true,
    fact: true,
    pow: true,
    floorCeil: false,
  ),
  easy(
    nonIntDiv: true,
    sqrt: true,
    cbrt: true,
    fact: true,
    pow: true,
    floorCeil: true,
  );

  const _Mode({
    required this.nonIntDiv,
    required this.sqrt,
    required this.cbrt,
    required this.fact,
    required this.pow,
    required this.floorCeil,
  });

  final bool nonIntDiv;
  final bool sqrt;
  final bool cbrt;
  final bool fact;
  final bool pow;
  final bool floorCeil;
}

final _memo = <String, Set<double>>{};
