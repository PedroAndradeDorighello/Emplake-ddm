import 'package:emplake/widgets/seed_color_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the center follows the brightness and has no saturation', () {
    final color = seedColorAt(const Offset(110, 110), 0.2);
    final hsv = HSVColor.fromColor(color);
    expect(hsv.saturation, 0);
    expect(hsv.value, closeTo(0.2, 0.02));
  });

  test('the rim keeps the chosen brightness', () {
    final color = seedColorAt(const Offset(220, 110), 0.4);
    final hsv = HSVColor.fromColor(color);
    expect(hsv.saturation, greaterThan(0.9));
    expect(hsv.value, closeTo(0.4, 0.02));
  });
}
