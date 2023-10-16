import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcboard/draw_painter.dart';

import 'board_controller.dart';
import 'board_item.dart';
import 'expandable_container.dart';

class BoardItemView extends StatelessWidget {

  BoardItem item;
  bool isSelected;
  BoardController controller;

  BoardItemView({
    Key? key,
    required this.controller,
    required this.item,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item is BoardItemText) {
      final widget = _textBoardItemView();
      return _selectableItem(widget);
    }
    if (item is BoardItemImage) {
      final widget = _imageBoardItemView();
      return _selectableItem(widget);
    }
    if (item is BoardItemDraw) {
      return _drawBoardItemView();
    }
    return _errorImage();
  }

  Widget _textBoardItemView() {
    final i = (item as BoardItemText);
    return Text(
      i.text ?? "",
      style: TextStyle(
        fontFamily: i.font,
        color: i.uiColor,
        fontSize: 24,
      ),
    );
  }

  Widget _imageBoardItemView() {
    final i = (item as BoardItemImage);
    File file = File(i.imagePath!);
    if (item.width > 0 && item.height > 0) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: item.width,
        height: item.height,
        errorBuilder: _errorImageBuilder(),
      );
    } else {
      return Image.file(
        file,
        errorBuilder: _errorImageBuilder(),
      );
    }
  }

  Widget _drawBoardItemView() {
    final i = (item as BoardItemDraw);
    return Container(
      color: const Color.fromARGB(100, 163, 93, 65),
      child: CustomPaint(
        painter: DrawPainter(
            points: i.drawPoints ?? [],
            strokeColor: i.uiDrawColor,
            strokeWidth: i.drawWidth,
            strokeCap: i.strokeCap,
            strokeJoin: i.strokeJoin),
      ),
    );
  }

  Widget _selectableItem(Widget child) {
    return isSelected ? _selectedItem(child) : _unselectItem(child);
  }

  Widget _unselectItem(Widget content) {
    return Positioned(
      top: item.top,
      left: item.left,
      child: Container(
        width: item.width,
        color: Colors.transparent,
        child: Transform(
          transform: item.matrix,
          child: GestureDetector(
            child: Container(color: Colors.transparent, child: content),
            onTap: () {
              selectItem(item);
            },
            onDoubleTap: () {
              selectItem(item);
            },
          ),
        ),
      ),
    );
  }

  Widget _selectedItem(Widget content) {
    return Positioned(
      top: item.top,
      left: item.left,
      child: AnimatedBuilder(
        animation: item.matrixNotifier,
        builder: (ctx, child) {
          return Transform(
            transform: item.matrix,
            child: measureContainer(
              Container(
                color: Colors.transparent,
                child: Container(child: content),
              ),
            ),
          );
        },
      ),
    );
  }

  void selectItem(BoardItem item) {
    if (item is BoardItemText || item is BoardItemImage) {
      controller.select(item);
    }
  }

  Widget _errorImage({String message = 'item error'}) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.red,
      child: Center(
        widthFactor: double.infinity,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 8, color: Colors.white),
        ),
      ),
    );
  }

  Widget measureContainer(Widget child) {
    if (item.width > 0 && item.height > 0) {
      return Container(
        width: item.width,
        color: Colors.transparent,
        child: child,
      );
    }
    return MeasureSize(
      onChange: (Size size) {
        if (size.width > 0 && size.height > 0) {
          item.width = size.width;
          item.height = size.height;
          controller.notifyListeners();
        }
      },
      child: Container(
        width: item.width,
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  ImageErrorWidgetBuilder _errorImageBuilder() {
    return (
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      return _errorImage(message: 'This image error');
    };
  }


}
