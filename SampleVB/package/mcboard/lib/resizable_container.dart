import 'package:flutter/material.dart';

enum Side { width, height }

class DragPoint extends StatefulWidget {
  static const double pointSize = 60.0;
  static const double pointPadding = 26;
  static const double stepSize = 1;
  static const double borderWidth = 2;

  static const double haftPointSize = pointSize / 2;
  static const double minSize = pointSize;
  static const double haftBorder = borderWidth / 2;
  final Function onDrag;

  DragPoint({Key? key, required this.onDrag});

  static Widget positioned({
    required double top,
    required double left,
    required Function onDrag,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: DragPoint(
        onDrag: onDrag,
      ),
    );
  }

  @override
  _DragPointState createState() => _DragPointState();
}

class _DragPointState extends State<DragPoint> {
  double? initX;
  double? initY;

  _handleDragStart(details) {
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
  }

  _handleDragUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      child: Container(
        color: Colors.transparent,
        width: DragPoint.pointSize,
        height: DragPoint.pointSize,
        padding: EdgeInsets.all(DragPoint.pointPadding),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1, color: Colors.grey),
            //shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}