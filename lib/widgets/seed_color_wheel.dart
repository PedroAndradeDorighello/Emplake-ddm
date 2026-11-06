import 'dart:math' as math;

import 'package:flutter/material.dart';

const _wheelSize = 220.0;

/// Cor na roda. O centro tem saturação zero e usa o brilho da barra.
Color seedColorAt(Offset local, double value, {double size = _wheelSize}) {
  final center = Offset(size / 2, size / 2);
  final radius = size / 2 - 4;
  final delta = local - center;
  final dist = delta.distance.clamp(0.0, radius);
  var hue = math.atan2(delta.dy, delta.dx) * 180 / math.pi;
  if (hue < 0) hue += 360;
  return HSVColor.fromAHSV(1, hue, dist / radius, value).toColor();
}

class SeedColorWheel extends StatefulWidget {
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
  State<SeedColorWheel> createState() => _SeedColorWheelState();
}

class _SeedColorWheelState extends State<SeedColorWheel> {
  late HSVColor _hsv;
  bool _dragging = false;
  ScrollHoldController? _releaseScroll;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.color);
  }

  @override
  void didUpdateWidget(SeedColorWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && widget.color != oldWidget.color) {
      _hsv = HSVColor.fromColor(widget.color);
    }
  }

  void _holdScroll() {
    _releaseScroll ??= Scrollable.maybeOf(context)?.position.hold(() {});
  }

  void _dropScroll() {
    _releaseScroll?.cancel();
    _releaseScroll = null;
  }

  void _pick(Offset local) {
    final next = seedColorAt(local, _hsv.value);
    setState(() => _hsv = HSVColor.fromColor(next));
    widget.onChanged(next);
  }

  void _finish() {
    _dragging = false;
    _dropScroll();
    widget.onChangeEnd(_hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: _wheelSize,
          height: _wheelSize,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              _dragging = true;
              _holdScroll();
              _pick(event.localPosition);
            },
            onPointerMove: (event) => _pick(event.localPosition),
            onPointerUp: (_) => _finish(),
            onPointerCancel: (_) => _finish(),
            child: CustomPaint(
              painter: _WheelPainter(_hsv),
              size: const Size(_wheelSize, _wheelSize),
            ),
          ),
        ),
        Row(
          children: [
            Icon(Icons.brightness_low, color: scheme.onSurfaceVariant),
            Expanded(
              child: Slider(
                value: _hsv.value,
                onChanged: (v) {
                  _dragging = true;
                  setState(() => _hsv = _hsv.withValue(v));
                  widget.onChanged(_hsv.toColor());
                },
                onChangeEnd: (v) {
                  final next = _hsv.withValue(v);
                  _dragging = false;
                  setState(() => _hsv = next);
                  widget.onChangeEnd(next.toColor());
                },
              ),
            ),
            Icon(Icons.brightness_high, color: scheme.onSurfaceVariant),
          ],
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

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
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0x00FFFFFF)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 1 - hsv.value)
        ..blendMode = BlendMode.srcOver,
    );
    canvas.restore();

    final rad = hsv.hue * math.pi / 180;
    final marker = center + Offset(math.cos(rad), math.sin(rad)) * radius * hsv.saturation;
    canvas.drawCircle(marker, 9, Paint()..color = Colors.white);
    canvas.drawCircle(marker, 6, Paint()..color = hsv.toColor());
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => oldDelegate.hsv != hsv;
}
