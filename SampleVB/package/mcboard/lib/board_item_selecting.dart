import 'package:flutter/material.dart';
import 'package:mcboard/resizable_container.dart';

import 'board_controller.dart';
import 'board_item.dart';
import 'gesture_controller.dart';

class BoardItemSelecting extends StatelessWidget {
  double cumulativeDy = 0;
  double cumulativeDx = 0;
  double cumulativeMid = 0;

  BoardItem get item => controller.selectedItem;

  double get left => item.left;

  double get top => item.top;

  double get width => item.width;

  double get height => item.height;

  BoardController controller;

  GestureController get gestureController => controller.gestureController;

  BoardItemSelecting(
    this.controller, {
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: item.top,
      left: item.left,
      child: AnimatedBuilder(
        animation: item.matrixNotifier,
        builder: (ctx, child) {
          return Transform(
            transform: item.matrix,
            child: Container(
              width: item.width,
              color: Colors.transparent,
              height: item.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _selectionBorder(DragPoint.borderWidth),
                  center(),
                  centerLeft(),
                  centerRight(),
                  centerTop(),
                  centerBottom(),
                  topLeft(),
                  topRight(),
                  bottomLeft(),
                  bottomRight(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void notifyListeners() {
    controller.notifyListeners();
  }

  Widget center() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DragPoint.haftPointSize - DragPoint.borderWidth),
        child: GestureDetector(
          onTapDown: (TapDownDetails details) {
            gestureController.startTranslate();
            gestureController.onScaleEnd = () {
              if (controller.hasSelectedItem) {
                final transformData = item.transformData;
                final translation = transformData.translation;
                item.left = item.left + translation.dx;
                item.top = item.top + translation.dy;

                item.printInfo("update");
              }
              gestureController.stopGesture();
              gestureController.onScaleEnd = () {};
            };
          },
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget centerLeft() {
    return _dragPoint(
      top: height / 2 - DragPoint.haftPointSize,
      left: -DragPoint.haftPointSize + DragPoint.haftBorder,
      onDrag: (dx, dy) {
        cumulativeDx -= dx;
        if (cumulativeDx >= DragPoint.stepSize) {
          increase(Side.width);
          item.left = left - DragPoint.stepSize;
          cumulativeDx = 0;
          controller.notifyListeners();
        } else if (cumulativeDx <= -DragPoint.stepSize) {
          if (left + DragPoint.stepSize <= left + width - DragPoint.minSize) {
            decrease(Side.width);
            item.left = left + DragPoint.stepSize;
            cumulativeDx = 0;
            controller.notifyListeners();
          }
        }
      },
    );
  }

  Widget centerRight() {
    return _dragPoint(
      top: height / 2 - DragPoint.haftPointSize,
      left: width - DragPoint.haftPointSize - DragPoint.haftBorder,
      onDrag: (dx, dy) {
        cumulativeDx += dx;
        if (cumulativeDx >= DragPoint.stepSize) {
          increase(Side.width);
          cumulativeDx = 0;
          notifyListeners();
        } else if (cumulativeDx <= -DragPoint.stepSize) {
          decrease(Side.width);
          cumulativeDx = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget centerTop() {
    return _dragPoint(
      top: -DragPoint.haftPointSize + DragPoint.haftBorder,
      left: width / 2 - DragPoint.haftPointSize,
      onDrag: (dx, dy) {
        cumulativeDy -= dy;
        if (cumulativeDy >= DragPoint.stepSize) {
          increase(Side.height);
          item.top -= DragPoint.stepSize;
          cumulativeDy = 0;
          notifyListeners();
        } else if (cumulativeDy <= -DragPoint.stepSize) {
          decrease(Side.height);
          item.top += DragPoint.stepSize;
          cumulativeDy = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget centerBottom() {
    return _dragPoint(
      top: height - DragPoint.haftPointSize - DragPoint.haftBorder,
      left: width / 2 - DragPoint.haftPointSize,
      onDrag: (dx, dy) {
        cumulativeDy += dy;
        if (cumulativeDy >= DragPoint.stepSize) {
          increase(Side.height);
          cumulativeDy = 0;
          notifyListeners();
        } else if (cumulativeDy <= -DragPoint.stepSize) {
          decrease(Side.height);
          cumulativeDy = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget topLeft() {
    return _dragPoint(
      top: -DragPoint.haftPointSize + DragPoint.haftBorder,
      left: -DragPoint.haftPointSize + DragPoint.haftBorder,
      onDrag: (dx, dy) {
        var mid = (dx + dy) / 2;
        cumulativeMid -= 2 * mid;
        if (cumulativeMid >= DragPoint.stepSize) {
          increase(Side.width, Side.height);
          item.top -= DragPoint.stepSize;
          item.left -= DragPoint.stepSize;
          cumulativeMid = 0;
          notifyListeners();
        } else if (cumulativeMid <= -DragPoint.stepSize) {
          if (left + DragPoint.stepSize <= left + width - DragPoint.minSize) {
            decrease(Side.width, Side.height);
            item.top += DragPoint.stepSize;
            item.left += DragPoint.stepSize;
            cumulativeMid = 0;
            notifyListeners();
          }
        }
      },
    );
  }

  Widget topRight() {
    return _dragPoint(
      top: -DragPoint.haftPointSize + DragPoint.haftBorder,
      left: width - DragPoint.haftPointSize - DragPoint.haftBorder,
      onDrag: (dx, dy) {
        var mid = (dx + (dy * -1)) / 2;
        cumulativeMid += 2 * mid;
        if (cumulativeMid >= DragPoint.stepSize) {
          increase(Side.width, Side.height);
          item.top -= DragPoint.stepSize;
          cumulativeMid = 0;
          notifyListeners();
        } else if (cumulativeMid <= -DragPoint.stepSize) {
          decrease(Side.width, Side.height);
          item.top += DragPoint.stepSize;
          cumulativeMid = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget bottomLeft() {
    return _dragPoint(
      top: height - DragPoint.haftPointSize - DragPoint.haftBorder,
      left: -DragPoint.haftPointSize + DragPoint.haftBorder,
      onDrag: (dx, dy) {
        var mid = ((dx * -1) + dy) / 2;

        cumulativeMid += 2 * mid;
        if (cumulativeMid >= DragPoint.stepSize) {
          increase(Side.width, Side.height);
          item.left -= DragPoint.stepSize;
          cumulativeMid = 0;
          notifyListeners();
        } else if (cumulativeMid <= -DragPoint.stepSize) {
          if (left + DragPoint.stepSize <= left + width - DragPoint.minSize) {
            decrease(Side.width, Side.height);
            item.left += DragPoint.stepSize;
            cumulativeMid = 0;
            notifyListeners();
          }
        }
      },
    );
  }

  Widget bottomRight() {
    return _dragPoint(
      top: height - DragPoint.haftPointSize - DragPoint.haftBorder,
      left: width - DragPoint.haftPointSize - DragPoint.haftBorder,
      onDrag: (dx, dy) {
        var mid = (dx + dy) / 2;
        cumulativeMid += 2 * mid;
        if (cumulativeMid >= DragPoint.stepSize) {
          increase(Side.width, Side.height);
          cumulativeMid = 0;
          notifyListeners();
        } else if (cumulativeMid <= -DragPoint.stepSize) {
          decrease(Side.width, Side.height);
          cumulativeMid = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget _selectionBorder(double borderWidth) {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.purple,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _dragPoint({
    required double top,
    required double left,
    required Function(double, double) onDrag,
  }) {
    if (item.width > 0 && item.height > 0) {
      return DragPoint.positioned(top: top, left: left, onDrag: onDrag);
    }
    return const SizedBox();
  }

  void increase(Side side1, [Side? side2]) {
    if (side1 == Side.width || side2 == Side.width) {
      item.width = setAlLeast(item.width + DragPoint.stepSize);
    }
    if (side1 == Side.height || side2 == Side.height) {
      item.height = setAlLeast(item.height + DragPoint.stepSize);
    }
  }

  void decrease([Side? side1, Side? side2]) {
    if (side1 == Side.width || side2 == Side.width) {
      item.width = setAlLeast(item.width - DragPoint.stepSize);
    }
    if (side1 == Side.height || side2 == Side.height) {
      item.height = setAlLeast(item.height - DragPoint.stepSize);
    }
  }

  double setAlLeast(double value) {
    return value >= DragPoint.minSize ? value : DragPoint.minSize;
  }
}
