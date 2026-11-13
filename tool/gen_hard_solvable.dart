import 'dart:io';

/// Gera lib/services/hard_solvable_numbers.dart com números solúveis no Difícil.
void main() {
  final ok = <int>[];
  for (var n = 1000; n <= 9999; n++) {
    if (_solvable(n)) ok.add(n);
  }
  final path = 'lib/services/hard_solvable_numbers.dart';
  final body = StringBuffer()
    ..writeln('/// Números 1000–9999 com ao menos uma solução no Difícil')
    ..writeln('/// (+ − × ÷, concatenação, unário − e |·|). Gerado por tool/gen_hard_solvable.dart.')
    ..writeln('const hardSolvableNumbers = <int>{')
    ..writeln(ok.map((n) => '  $n,').join('\n'))
    ..writeln('};')
    ..writeln()
    ..writeln('bool isHardSolvable(int n) => hardSolvableNumbers.contains(n);');
  File(path).writeAsStringSync(body.toString());
  stdout.writeln('wrote $path count=${ok.length} includes7464=${ok.contains(7464)}');
}

bool _solvable(int n) {
  final d = [
    n ~/ 1000,
    (n ~/ 100) % 10,
    (n ~/ 10) % 10,
    n % 10,
  ];
  for (var split = 1; split <= 3; split++) {
    final left = _values(d.sublist(0, split));
    final right = _values(d.sublist(split));
    for (final a in left) {
      for (final b in right) {
        if ((a - b).abs() < 1e-9) return true;
      }
    }
  }
  return false;
}

Set<double> _values(List<int> digits) {
  final key = digits.join();
  return _memo.putIfAbsent(key, () {
    final out = <double>{};
    out.add(double.parse(key));
    if (digits.length == 1) {
      out.add(-out.first);
      out.add(out.first.abs());
      return out;
    }
    for (var i = 1; i < digits.length; i++) {
      final L = _values(digits.sublist(0, i));
      final R = _values(digits.sublist(i));
      for (final a in L) {
        for (final b in R) {
          out.add(a + b);
          out.add(a - b);
          out.add(a * b);
          if (b.abs() > 1e-12) {
            final q = a / b;
            if ((q - q.roundToDouble()).abs() < 1e-9) out.add(q.roundToDouble());
          }
        }
      }
    }
    final copy = out.toList();
    for (final v in copy) {
      out.add(-v);
      out.add(v.abs());
    }
    return out;
  });
}

final _memo = <String, Set<double>>{};
