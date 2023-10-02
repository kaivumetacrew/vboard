import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:mcboard/gesture_config.dart';

class GestureController extends ValueNotifier<GestureConfigs> {
  GestureController() : super(GestureConfigs());
  VoidCallback? onScaleStart;
  VoidCallback? onScaleEnd;
  GestureDragStartCallback? onPanStart;
  GestureDragUpdateCallback? onPanUpdate;

  void stopGesture() {
    value = GestureConfigs()
      ..shouldTranslate = false
      ..shouldScale = false
      ..shouldRotate = false;
  }

  void startGesture() {
    value = GestureConfigs()
      ..shouldTranslate = true
      ..shouldScale = true
      ..shouldRotate = true;
  }

  void startTranslate() {
    if(value.shouldTranslate != true){
      value = GestureConfigs()
        ..shouldTranslate = true
        ..shouldScale = false
        ..shouldRotate = false;
    }
  }

  void startScale() {
    value = GestureConfigs()
      ..shouldTranslate = false
      ..shouldScale = true
      ..shouldRotate = false;
  }

  static Point? selectedPoint = null;

  static Function onDrag = (double dx, double dy) {};

}
