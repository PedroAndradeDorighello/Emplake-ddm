import 'dart:math' as math;

import 'package:flutter/material.dart';

class SeedColorWheel extends StatelessWidget {
  const SeedColorWheel({
    super.key,
    required this.color,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final Color color;
  final ValueChanged<Color> onChanged;
  final ValueChanged<Color> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final hsv = HSVColor.fromColor(color);
    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: GestureDetector(
            onPanDown: (d) => onChanged(_colorAt(d.localPosition, hsv.value)),
            onPanUpdate: (d) => onChanged(_colorAt(d.localPosition, hsv.value)),
            onPanEnd: (_) => onChangeEnd(color),
            child: CustomPaint(
              painter: _WheelPainter(color),
              size: const Size(220, 220),
            ),
          ),
        ),
        Slider(
          value: hsv.value,
          onChanged: (v) => onChanged(hsv.withValue(v).toColor()),
          onChangeEnd: (v) => onChangeEnd(hsv.withValue(v).toColor()),
        ),
      ],
    );
  }

  Color _colorAt(Offset local, double value) {
    const size = 220.0;
    final center = const Offset(size / 2, size / 2);
    final radius = size / 2 - 4;
    final delta = local - center;
    final dist = delta.distance.clamp(0.0, radius);
    var hue = math.atan2(delta.dy, delta.dx) * 180 / math.pi;
    if (hue < 0) hue += 360;
    return HSVColor.fromAHSV(1, hue, dist / radius, value).toColor();
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final hsv = HSVColor.fromColor(color);

    canvas.saveLayer(rect.inflate(2), Paint());
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: [
            for (var h = 0; h <= 360; h += 20)
              HSVColor.fromAHSV(1, (h % 360).toDouble(), 1, 1).toColor(),
          ],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, const Color(0x00FFFFFF)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 1 - hsv.value)
        ..blendMode = BlendMode.srcATop,
    );
    canvas.restore();

    final rad = hsv.hue * math.pi / 180;
    final marker = center +
        Offset(math.cos(rad), math.sin(rad)) * radius * hsv.saturation;
    canvas.drawCircle(marker, 9, Paint()..color = Colors.white);
    canvas.drawCircle(marker, 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => oldDelegate.color != color;
}
