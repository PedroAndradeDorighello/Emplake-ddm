import 'package:emplake/theme/app_theme.dart';
import 'package:emplake/widgets/seed_color_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preset themes keep the luminosity bar at full', () {
    final hsv = seedWheelHsv(const Color(0xFF0D7377), fullLuminosity: true);
    expect(hsv.value, 1);
    expect(hsv.saturation, HSVColor.fromColor(const Color(0xFF0D7377)).saturation);
  });

  test('the center follows the brightness and has no saturation', () {
    final color = seedColorAt(const Offset(110, 110), 0.2);
    final hsv = HSVColor.fromColor(color);
    expect(hsv.saturation, 0);
    expect(hsv.value, closeTo(0.2, 0.02));
  });

  test('lower luminosity darkens the scheme', () {
    const scheme = ColorScheme.light(primary: Color(0xFF6750A4));
    final dim = applySeedLuminosity(scheme, 0.4);
    expect(dim.primary.computeLuminance(), lessThan(scheme.primary.computeLuminance()));
    expect(applySeedLuminosity(scheme, 1).primary, scheme.primary);
  });

  test('the rim keeps the chosen brightness', () {
    final color = seedColorAt(const Offset(220, 110), 0.4);
    final hsv = HSVColor.fromColor(color);
    expect(hsv.saturation, greaterThan(0.9));
    expect(hsv.value, closeTo(0.4, 0.02));
  });
}
