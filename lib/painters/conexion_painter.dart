import 'dart:math';
import 'package:flutter/material.dart';

/// Painter personalizado para dibujar conexiones entre nodos en modo debug
class ConexionPainter extends CustomPainter {
  final Offset inicio;
  final Offset fin;
  final int distancia;

  ConexionPainter({
    required this.inicio,
    required this.fin,
    required this.distancia,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar línea de conexión
    final paint = Paint()
      ..color = Colors.green.shade600.withAlpha((0.7 * 255).round())
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(inicio, fin, paint);

    // Dibujar flecha en el destino
    final angle = (fin - inicio).direction;
    final arrowSize = 8.0;

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

    final arrowPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);

    // Dibujar etiqueta con la distancia en el centro
    final center = Offset(
      (inicio.dx + fin.dx) / 2,
      (inicio.dy + fin.dy) / 2,
    );

    final textSpan = TextSpan(
      text: '${distancia}m',
      style: TextStyle(
        color: Colors.green.shade800,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.white.withAlpha((0.9 * 255).round()),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(ConexionPainter oldDelegate) {
    return oldDelegate.inicio != inicio ||
        oldDelegate.fin != fin ||
        oldDelegate.distancia != distancia;
  }
}
