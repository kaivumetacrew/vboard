import 'package:flutter/material.dart';
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
}
