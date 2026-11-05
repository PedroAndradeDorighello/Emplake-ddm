import 'package:flutter/material.dart';

/// Escala tipografia e peças do jogo pela largura da janela.
class ScreenScale {
  const ScreenScale(this.width);

  final double width;

  bool get compact => width < 520;
  bool get wide => width >= 800;

  /// Multiplicador em cima do tamanho escolhido nas configurações.
  double get text => switch (width) {
        < 380 => 0.88,
        < 720 => 1,
        < 1100 => 1.08,
        _ => 1.16,
      };

  double get pagePadding => compact ? 12 : 24;

  double digitSize(double boardWidth) {
    final usable = boardWidth.isFinite ? boardWidth : 360.0;
    return (usable / 9).clamp(36.0, 72.0);
  }

  static ScreenScale of(BuildContext context) =>
      ScreenScale(MediaQuery.sizeOf(context).width);
}
