import 'package:flutter/material.dart';

import '../board_util.dart';
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

  BoardTransformData get transformData {
    var array = matrix.applyToVector3Array([0, 0, 0, 1, 0, 0]);
    Offset delta = Offset(array[3] - array[0], array[4] - array[1]);
    return BoardTransformData(
      translation: Offset(array[0], array[1]),
      delta: delta,
    );
  }

  static Matrix4 compose(Matrix4? matrix, Matrix4? translationMatrix,
      Matrix4? scaleMatrix, Matrix4? rotationMatrix) {
    matrix ??= Matrix4.identity();
    if (translationMatrix != null) matrix = translationMatrix * matrix;
    if (scaleMatrix != null) matrix = scaleMatrix * matrix;
    if (rotationMatrix != null) matrix = rotationMatrix * matrix;
    return matrix!;
  }
}

class BoardItemImage extends BoardItem {
  String? storagePath;
  String? savedPath;

  String? get imagePath => storagePath ?? savedPath;

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
  List<BoardPoint>? drawPoints;
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

class BoardTransformData {
  Offset translation;
  Offset delta;

  double get scale => delta.distance;

  double get rotation => delta.direction;

  BoardTransformData({
    required this.translation,
    required this.delta,
  });
}
