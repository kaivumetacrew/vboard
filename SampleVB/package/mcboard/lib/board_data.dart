import 'dart:ui';

import 'board_item.dart';

class BoardData {
  int id;

  String name;

  String? backgroundColor;

  String? backgroundImagePath;

  List<BoardItem> items;

  double borderWidth;
  double borderRadius;
  String? borderColor;

  BoardData({
    required this.id,
    required this.name,
    required this.items,
    this.backgroundColor,
    this.backgroundImagePath,
    this.borderWidth = 0,
    this.borderRadius = 0,
    this.borderColor,
  });

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
