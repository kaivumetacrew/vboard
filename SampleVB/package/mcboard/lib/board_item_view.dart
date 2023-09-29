import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcboard/draw_painter.dart';

import 'board_item.dart';

class BoardItemView extends StatelessWidget {
  BoardItem item;

  bool isSelected;

  Function(BoardItem) onTap;

  /// Space between selected item widget and border
  EdgeInsets get _boardItemMargin => const EdgeInsets.all(2.0);

  BoardItemView({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
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
    return GestureDetector(
      child: Text(
        i.text!,
        style: TextStyle(
          fontFamily: i.font,
          color: i.uiColor,
          fontSize: 24,
        ),
      ),
      onTap: () {
        onTap(i);
      },
    );
  }

  Widget _imageBoardItemView() {
    final i = (item as BoardItemImage);
    Widget imageWidget;
    if (item is BoardItemImage) {
      imageWidget = Image.file(File(i.imagePath!), errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return _errorImage(message: 'This image error');
      });
    } else {
      return _errorImage();
    }
    return GestureDetector(
      child: imageWidget,
      onTap: () {
        onTap(item);
      },
    );
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

  Widget _selectableItem(Widget widget) {
    return isSelected ? _selectedItem(widget) : _unselectItem(widget);
  }

  Widget _unselectItem(Widget itemWidget) {
    return Transform(
      transform: item.matrix,
      child: Container(
        margin: _boardItemMargin,
        child: Container(
          child: itemWidget,
        ),
      ),
    );
  }

  Widget _selectedItem(Widget itemWidget) {
    return AnimatedBuilder(
      animation: item.matrixNotifier,
      builder: (ctx, child) {
        final transData = item.transformData;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Transform(
              transform: item.matrix,
              child: Container(
                margin: _boardItemMargin,
                child: Container(child: itemWidget),
              ),
            ),
            _fillPositioned(
              Transform(
                transform: item.matrix,
                child: _selectionBorder(0.5 + 1 / transData.scale),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _selectionBorder(double borderWidth) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.purple,
          width: borderWidth,
        ),
      ),
      child: Container(),
    );
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

  Widget _fillPositioned(Widget child) {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      left: 0,
      child: child,
    );
  }
}
