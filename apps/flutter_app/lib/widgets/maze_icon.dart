import 'dart:math';

import 'package:flutter/material.dart';

/// A maze icon widget drawn with CustomPainter, matching the SVG maze logo.
///
/// Uses [color] (defaults to theme primary) so it adapts to any theme.
class MazeIcon extends StatelessWidget {
  const MazeIcon({super.key, this.size = 80, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        size: Size.square(size),
        painter: _MazeIconPainter(color: iconColor),
      ),
    );
  }
}

class _MazeIconPainter extends CustomPainter {
  _MazeIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    final cy = s / 2;
    final scale = s / 64; // SVG viewBox is 64x64

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 3.5 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Helper to draw an arc given center, radius, start/end angles in degrees.
    // Angles are SVG-style: 0°=right, 90°=bottom, clockwise.
    void drawArc(double r, double startDeg, double endDeg) {
      final rect = Rect.fromCircle(
        center: Offset(cx, cy),
        radius: r * scale,
      );
      final startRad = startDeg * pi / 180;
      // Sweep clockwise from start to end.
      var sweepDeg = endDeg - startDeg;
      if (sweepDeg <= 0) sweepDeg += 360;
      final sweepRad = sweepDeg * pi / 180;
      canvas.drawArc(rect, startRad, sweepRad, false, strokePaint);
    }

    // Helper to draw a radial wall line.
    void drawWall(double angle, double r1, double r2) {
      final rad = angle * pi / 180;
      canvas.drawLine(
        Offset(cx + r1 * scale * cos(rad), cy + r1 * scale * sin(rad)),
        Offset(cx + r2 * scale * cos(rad), cy + r2 * scale * sin(rad)),
        strokePaint,
      );
    }

    // Outer ring r=27, gap at lower-left (120° to 150°)
    // Arc from 150° CW to 120° (the long way, 330°)
    drawArc(27, 150, 120);

    // Middle ring r=18, gap at upper-left (210° to 240°)
    // Arc from 240° CW to 210° (the long way, 330°)
    drawArc(18, 240, 210);

    // Inner ring r=9, gap at upper-right (290° to 340°)
    // Arc from 340° CW to 290° (the long way, 310°)
    drawArc(9, 340, 290);

    // Radial walls
    drawWall(0, 9, 18); // 3 o'clock, inner corridor
    drawWall(90, 18, 27); // 6 o'clock, outer corridor
    drawWall(180, 9, 18); // 9 o'clock, inner corridor
    drawWall(270, 18, 27); // 12 o'clock, outer corridor

    // Center dot
    canvas.drawCircle(Offset(cx, cy), 2.5 * scale, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _MazeIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
