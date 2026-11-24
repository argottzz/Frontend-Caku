import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Latar bertekstur kontur topografi warna sage.
///
/// Dipakai di area kosong (splash, empty state, panel merek) agar latar putih
/// tetap terasa bernuansa hutan tanpa menambah aset gambar. Garis digambar
/// dengan [CustomPainter] supaya ikut diskalakan di layar apa pun.
class ForestPattern extends StatelessWidget {
  const ForestPattern({
    super.key,
    this.color = AppColors.sage,
    this.opacity = 0.16,
    this.child,
  });

  final Color color;
  final double opacity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ContourPainter(color.withValues(alpha: opacity)),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _ContourPainter extends CustomPainter {
  const _ContourPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Deretan lengkung kontur yang mengalir dari kiri bawah ke kanan atas,
    // meniru garis ketinggian pada peta topografi.
    const lineCount = 7;
    for (var i = 0; i < lineCount; i++) {
      final shift = size.height * (0.12 * i) - size.height * 0.15;
      final amplitude = 26.0 + i * 6;
      final path = Path()..moveTo(-20, size.height * 0.55 + shift);

      for (var x = -20.0; x <= size.width + 20; x += 24) {
        final y =
            size.height * 0.55 + shift + amplitude * _wave(x / size.width, i);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  double _wave(double t, int index) {
    // Dua gelombang dengan fase berbeda agar kontur tidak tampak berulang.
    return 0.55 * _sin(t * 6.3 + index * 0.6) +
        0.45 * _sin(t * 2.1 - index * 0.9);
  }

  /// Sinus sederhana berbasis Taylor hingga orde 7 — cukup halus untuk garis
  /// kontur dan tidak bergantung pada dart:math.
  double _sin(double x) {
    const twoPi = 6.283185307179586;
    var value = x % twoPi;
    if (value > 3.141592653589793) value -= twoPi;
    final x2 = value * value;
    return value * (1 - x2 / 6 * (1 - x2 / 20 * (1 - x2 / 42 * (1 - x2 / 72))));
  }

  @override
  bool shouldRepaint(_ContourPainter oldDelegate) => oldDelegate.color != color;
}
