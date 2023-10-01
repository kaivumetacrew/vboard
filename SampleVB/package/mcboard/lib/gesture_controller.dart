import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:mcboard/gesture_config.dart';

class GestureController extends ValueNotifier<GestureConfigs> {
  GestureController() : super(GestureConfigs());

  void startTranslate() {
    value = GestureConfigs()
      ..shouldTranslate = true
      ..shouldScale = false
      ..shouldRotate = false;
  }

  void startScale() {
    value = GestureConfigs()
      ..shouldTranslate = false
      ..shouldScale = true
      ..shouldRotate = false;
  }

  static Point? selectedPoint = null;

  static Function onDrag = (double dx, double dy) {};

  GestureDragStartCallback onPanStart = (DragStartDetails details) {
    final point = selectedPoint;
    if (point == null) return;
    point.x = details.globalPosition.dx;
    point.y = details.globalPosition.dy;
  };

  GestureDragUpdateCallback onPanUpdate = (DragUpdateDetails details) {
    final point = selectedPoint;
    if (point == null) return;
    var dx = details.globalPosition.dx - point.x;
    var dy = details.globalPosition.dy - point.y;
    point.x = details.globalPosition.dx;
    point.y = details.globalPosition.dy;
    onDrag(dx, dy);
  };
}
