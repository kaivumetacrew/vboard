

import 'package:flutter/material.dart';

import 'board_point.dart';

class DrawPainter extends CustomPainter {
  DrawPainter({
    required this.points,
    this.strokeColor = Colors.black,
    this.strokeWidth = 10,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
  })  : _penStyle = Paint(),
        super() {
    _penStyle
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..strokeJoin = strokeJoin;
  }

  final Paint _penStyle;
  List<Point> points;
  Color strokeColor;
  double strokeWidth;
  StrokeCap strokeCap;
  StrokeJoin strokeJoin;

  @override
  void paint(Canvas canvas, _) {
    if (points.isEmpty) {
      return;
    }
    for (int i = 0; i < (points.length - 1); i++) {
      if (points[i + 1].type == PointType.move) {
        _penStyle.strokeWidth *= points[i].pressure;
        canvas.drawLine(
          points[i].offset,
          points[i + 1].offset,
          _penStyle,
        );
      } else {
        canvas.drawCircle(
          points[i].offset,
          (_penStyle.strokeWidth / 2) * points[i].pressure,
          _penStyle,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}