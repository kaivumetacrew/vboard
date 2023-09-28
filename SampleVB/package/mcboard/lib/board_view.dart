

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcboard/draw_view.dart';
import 'package:screenshot/screenshot.dart';

import 'board_data.dart';
import 'board_item.dart';
import 'board_item_view.dart';
import 'gesture_detector.dart';
import 'util.dart';
import 'board_controller.dart';

class BoardView extends StatefulWidget {
  static const double widthDip = 320;
  static const double heightDip = 426;

  static const double ratio = 3 / 4;

  double scale = 1;

  BoardController controller;

  BoardView({
    Key? key,
    required this.controller,
    this.scale = 1,
  }) : super(key: key);

  @override
  State createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  BoardController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.drawController.onDrawEnd = () => {_onDrawEnd()};
  }

  @override
  void didUpdateWidget(covariant BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller.screenshotController,
      child: Container(
        width: BoardView.widthDip,
        height: BoardView.heightDip,
        decoration: _decoration(controller.value),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(controller.value.borderRadius-controller.value.borderWidth),
          child: Stack(
            children: [
              _background(controller.value),
              _itemsContainer(),
              _drawContainer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Board item widgets
  List<Widget> get boardItemWidgets =>
      controller.value.items.map(_itemToWidget).toList();

  Widget _itemToWidget(BoardItem e) {
    return BoardItemView(
      key: Key(e.id.toString()),
      item: e,
      isSelected: e.equal(controller.selectedItem),
      onTap: (e) {
        if (e is BoardItemText || e is BoardItemImage) {
          controller.select(e);
          controller.onItemTap(e);
        }
      },
    );
  }

  BoxDecoration _decoration(BoardData data){
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(data.borderRadius)),
      color: Colors.transparent,
      border: Border.all(
        color: BoardUtil.parseColor(data.borderColor, orElse: Colors.black),
        width: data.borderWidth,
      ),
    );
  }

  Widget _background(BoardData data) {
    Widget background() {
      final image = data.backgroundImagePath;
      if (image != null) {
        return Image.file(File(image), fit: BoxFit.cover);
      }
      final color = data.backgroundColor;
      if (color != null) {
        return Container(color: BoardUtil.parseColor(color, orElse: Colors.white));
      }
      return Container(color: Colors.white);
    }

    return background();
  }

  /// Container for board widgets
  Widget _itemsContainer() {
    return Container(
        width: double.infinity,
        height: double.infinity,
        //color: Colors.red,
        child: MatrixGestureDetector(
          onScaleStart: () {},
          onScaleEnd: () {},
          scale: widget.scale,
          onMatrixUpdate: _onMatrixUpdate,
          child: Stack(children: boardItemWidgets),
        ));
  }

  /// Container for user draw by finger
  Widget _drawContainer() {
    return ValueListenableBuilder(
      valueListenable: controller.isDrawingNotifier,
      builder: (
        BuildContext context,
        bool value,
        Widget? child,
      ) {
        if (value) {
          return Positioned(
            top: 0,
            left: 0,
            child: DrawView(
              width: BoardView.widthDip,
              height: BoardView.heightDip,
              controller: controller.drawController,
            ),
          );
        }
        return const SizedBox(
          width: 0,
          height: 0,
        );
      },
    );
  }

  /// Callback on gesture
  void _onMatrixUpdate(
    MatrixGestureDetectorState state,
    Matrix4 matrix,
    Matrix4 translationDeltaMatrix,
    Matrix4 scaleDeltaMatrix,
    Matrix4 rotationDeltaMatrix,
  ) {
    if (controller.isDrawing) {
      return;
    }
    if (controller.selectedItem == BoardItem.none) {
      return;
    }
    if (controller.selectedItem.id != state.id) {
      state.id = controller.selectedItem.id;
      state.update(controller.selectedItem.matrix);
      return;
    }
    controller.selectedItem.matrixNotifier.value = matrix;
  }

  /// Callback on finger draw tap up
  void _onDrawEnd() {
    controller.addNewItem(BoardItemDraw(drawPoints: controller.drawController.points));
    controller.drawController.clear();
  }
}
