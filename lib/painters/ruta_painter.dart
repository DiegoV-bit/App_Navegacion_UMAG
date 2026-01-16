import 'dart:math';
import 'package:flutter/material.dart';

/// Painter personalizado para dibujar segmentos de la ruta calculada
class RutaPainter extends CustomPainter {
  final Offset inicio;
  final Offset fin;

  RutaPainter({
    required this.inicio,
    required this.fin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar borde blanco para dar contraste
    final paintBorde = Paint()
      ..color = Colors.white.withAlpha((0.5 * 255).round())
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(inicio, fin, paintBorde);

    // Dibujar línea principal de la ruta
    final paint = Paint()
      ..color = Colors.blue.shade600.withAlpha((0.8 * 255).round())
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(inicio, fin, paint);

    // Dibujar flecha direccional
    final angle = (fin - inicio).direction;
    final arrowSize = 10.0;

    final arrowPath = Path();
    arrowPath.moveTo(
      fin.dx - arrowSize * cos(angle - 0.4),
      fin.dy - arrowSize * sin(angle - 0.4),
    );
    arrowPath.lineTo(fin.dx, fin.dy);
    arrowPath.lineTo(
      fin.dx - arrowSize * cos(angle + 0.4),
      fin.dy - arrowSize * sin(angle + 0.4),
    );
    arrowPath.close();

    final arrowPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(RutaPainter oldDelegate) {
    return oldDelegate.inicio != inicio || oldDelegate.fin != fin;
  }
}
