import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcboard/board_item_dragger.dart';
import 'package:mcboard/draw_painter.dart';
import 'package:mcboard/resizable_container.dart';

import 'board_controller.dart';
import 'board_item.dart';
import 'expandable_container.dart';

class BoardItemView extends StatelessWidget {
  /// Space between selected item widget and border
  EdgeInsets get _boardItemMargin => const EdgeInsets.all(2.0);

  BoardItem item;
  bool isSelected;
  BoardController controller;
  BoardItemEdge paner;
  Function(BoardItem) onTap;

  BoardItemView({
    Key? key,
    required this.controller,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : paner = BoardItemEdge(controller, item);

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
          child: Container(
            margin: _boardItemMargin,
            child: GestureDetector(
              child: Container(child: content),
              onTap: () {
                onTap(item);
              },
            ),
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        child: Container(child: content),
                        onTap: () {
                          onTap(item);
                        },
                      ),

                      _selectionBorder(1 + 1 / item.transformData.scale),

                      paner.centerLeft(),

                      paner.centerRight(),

                      paner.centerTop(),

                      paner.centerBottom(),

                      paner.topLeft(),

                      paner.topRight(),

                      paner.bottomLeft(),

                      paner.bottomRight(),

                    ],
                  ),
                ),
              ));
        },
      ),
    );
  }

  Widget _selectionBorder(double borderWidth) {
    return _fillPositioned(
      Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.purple,
            width: 2,
          ),
        ),
      ),
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

  Widget measureContainer(Widget child) {
    if (item.width > 0 && item.height > 0) {
      return Container(
        width: item.width,
        color: Colors.amber,
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
        color: Colors.amber,
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
