import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mcboard/board.dart';
import 'package:mcboard/board_item_selecting.dart';
import 'package:mcboard/draw_view.dart';
import 'package:screenshot/screenshot.dart';

import 'board_config.dart';
import 'board_item.dart';
import 'board_item_view.dart';
import 'board_util.dart';
import 'board_widgets.dart';
import 'gesture_detector.dart';

class BoardView extends StatefulWidget {
  BoardController controller;
  double? width;
  double? height;

  BoardView({
    Key? key,
    this.width,
    this.height,
    required this.controller,
  }) : super(key: key);

  @override
  State createState() => BoardViewState();
}

class BoardViewState extends State<BoardView> {
  BoardController get controller => widget.controller;

  BoardData get data => controller.data;

  @override
  void initState() {
    super.initState();
    controller.drawController.onDrawEnd = () => {_onDrawEnd()};
  }

  @override
  Widget build(BuildContext context) {
    return BoardContainer(
      width: widget.width,
      height: widget.height,
      child: _boardContent(),
    );
  }

  Widget _boardContent(){
    return Screenshot(
      controller: controller.screenshotController,
      child: Container(
        width: BoardConfigs.widthDip,
        height: BoardConfigs.heightDip,
        decoration: _decoration(data),
        child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (
                BuildContext context,
                BoardData data,
                Widget? child,
                ) {
              final radius = data.borderRadius - data.borderWidth;
              return ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Stack(
                  children: [
                    _background(data),
                    _itemsContainer(data),
                    //_drawContainer(data),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget _itemToWidget(BoardItem e) {
    return BoardItemView(
      controller: controller,
      key: Key(e.id.toString()),
      item: e,
      isSelected: e.equal(controller.selectedItem),
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
        return Container(
            color: BoardUtil.parseColor(color, orElse: Colors.white));
      }
      return Container(color: Colors.white);
    }

    return background();
  }

  /// Container for board widgets
  Widget _itemsContainer(BoardData data) {
    final boardItems = data.items.map(_itemToWidget).toList();
    if (controller.hasSelectedItem) {
      boardItems.add(BoardItemSelecting(controller));
      boardItems.add(_selectedItemTools(controller));
      boardItems.add(_selectedItemRotateButton(controller));
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: MatrixGestureDetector(
        controller: controller.gestureController,
        clipChild: true,
        scale: BoardConfigs.scale,
        onMatrixUpdate: _onMatrixUpdate,
        child: Container(
          color: Colors.transparent,
          // MUST HAVE BACKGROUND IF IT NONE, WILL GET ERROR WHEN DRAG
          child: Stack(children: boardItems),
        ),
      ),
    );
  }

  Widget _selectedItemToolButton(
      BoardController controller, IconData icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: squareContainer(
        size: 24,
        child: Center(
          child: Icon(
            icon,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _selectedItemTools(BoardController controller) {
    if (!controller.hasSelectedItem) {
      return goneBox;
    }
    final item = controller.selectedItem;
    return Positioned(
      top: item.top - 50,
      left: item.left,
      child: AnimatedBuilder(
        animation: item.matrixNotifier,
        builder: (ctx, child) {
          final transformData = item.transformData;
          Matrix4 matrix = Matrix4.identity();
          matrix.translate(
              transformData.translation.dx, transformData.translation.dy);
          return Transform(
            transform: matrix,
            child: decorateContainer(
              borderColor: Colors.grey,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              radius: 100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _selectedItemToolButton(
                    controller,
                    Icons.copy_rounded,
                    () {},
                  ),
                  _selectedItemToolButton(
                    controller,
                    Icons.delete_outline,
                    () {},
                  ),
                  _selectedItemToolButton(
                    controller,
                    Icons.more_horiz,
                    () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _selectedItemRotateButton(BoardController controller) {
    if (!controller.hasSelectedItem) {
      return goneBox;
    }
    final item = controller.selectedItem;
    const rotationButtonSpacing = 50.0;
    return Positioned(
      top: item.top - rotationButtonSpacing,
      left: item.left - rotationButtonSpacing,
      child: AnimatedBuilder(
        animation: item.matrixNotifier,
        builder: (ctx, child) {
          final transformData = item.transformData;
          Matrix4 matrix = Matrix4.identity();
          matrix.rotateX(transformData.rotation);
          matrix.translate(
              transformData.translation.dx, transformData.translation.dy);
          return Transform(
            transform: matrix,
            child: SizedBox(
              width: item.width + rotationButtonSpacing * 2,
              height: item.height + rotationButtonSpacing * 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      child: squareContainer(
                        size: rotationButtonSpacing,
                        child: Center(
                          child: circleContainer(
                            size: 24,
                            borderColor: Colors.grey,
                            color: Colors.white,
                            child: Center(
                              child: Icon(
                                Icons.rotate_right_rounded,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Container for user draw by finger
  Widget _drawContainer(BoardData data) {
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
              width: BoardConfigs.widthDip,
              height: BoardConfigs.heightDip,
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
    if (!controller.hasSelectedItem) {
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
    controller.addNewItem(BoardItemDraw(), (item) {
      item.drawPoints = controller.drawController.points;
    });
    controller.drawController.clear();
  }
}
