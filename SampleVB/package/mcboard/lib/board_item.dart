import 'package:flutter/material.dart';
import '../util.dart';
import 'board_point.dart';

abstract class BoardItem {
  int id = -1;
  Key? key;
  int lastUpdate = 0;

  ValueNotifier<Matrix4> matrixNotifier = ValueNotifier(Matrix4.identity());

  Matrix4 get matrix => matrixNotifier.value;

  BoardItem({
    this.key,
    this.id = -1,
  });

  bool equal(BoardItem? item) {
    if (item == null) return false;
    return id == item.id;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static BoardItem none = BoardItemText(id: -1);

  bool get isNone => id == -1;
}

class BoardItemImage extends BoardItem {
  String? storageImagePath;
  String? savedImagePath;

  String? get imagePath => storageImagePath ?? savedImagePath;

  BoardItemImage({
    super.key,
    super.id = -1,
  });
}

class BoardItemText extends BoardItem {
  String? text;
  String? font;
  String? textColor;

  Color get uiColor =>
      textColor == null ? Colors.black : BoardUtil.parseColor(textColor);

  BoardItemText({
    super.key,
    super.id = -1,
    this.text,
    this.font,
    this.textColor,
  });
}

class BoardItemDraw extends BoardItem {
  List<Point>? drawPoints;
  String drawColor;
  double drawWidth;

  StrokeCap strokeCap;
  StrokeJoin strokeJoin;

  BoardItemDraw({
    super.key,
    super.id = -1,
    this.drawPoints,
    this.drawColor = "#000000",
    this.drawWidth = 3,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
  });

  // Draw

  Color get uiDrawColor =>
      drawColor == null ? Colors.black : BoardUtil.parseColor(drawColor);
}
