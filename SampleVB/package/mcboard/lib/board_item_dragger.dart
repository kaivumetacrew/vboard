import 'package:flutter/cupertino.dart';
import 'package:mcboard/resizable_container.dart';

import 'board_controller.dart';
import 'board_item.dart';

class BoardItemEdge {
  BoardItem item;
  BoardController controller;
  double cumulativeDy = 0;
  double cumulativeDx = 0;
  double cumulativeMid = 0;

  double get left => item.left;

  double get top => item.top;

  double get width => item.width;

  double get height => item.height;

  void notifyListeners() {
    controller.notifyListeners();
  }

  BoardItemEdge(this.controller, this.item);

  Widget centerLeft() {
    return _dragPoint(
      top: height / 2 - haftDragPointSize,
      left: -haftDragPointSize,
      onDrag: (dx, dy) {
        cumulativeDx -= dx;
        if (cumulativeDx >= stepSize) {
          increase(Side.width);
          item.left = left - stepSize;
          cumulativeDx = 0;
          controller.notifyListeners();
        } else if (cumulativeDx <= -stepSize) {
          if (left + stepSize <= left + width - minSize) {
            decrease(Side.width);
            item.left = left + stepSize;
            cumulativeDx = 0;
            controller.notifyListeners();
          }
        }
      },
    );
  }

  Widget centerRight() {
    return _dragPoint(
      top: height / 2 - dragPointSize / 2,
      left: width - dragPointSize / 2,
      onDrag: (dx, dy) {
        cumulativeDx += dx;
        if (cumulativeDx >= stepSize) {
          increase(Side.width);
          cumulativeDx = 0;
          notifyListeners();
        } else if (cumulativeDx <= -stepSize) {
          decrease(Side.width);
          cumulativeDx = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget centerTop() {
    return _dragPoint(
      top: -dragPointSize / 2,
      left: width / 2 - dragPointSize / 2,
      onDrag: (dx, dy) {
        cumulativeDy -= dy;
        if (cumulativeDy >= stepSize) {
          increase(Side.height);
          item.top -= stepSize;
          cumulativeDy = 0;
          notifyListeners();
        } else if (cumulativeDy <= -stepSize) {
          decrease(Side.height);
          item.top += stepSize;
          cumulativeDy = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget centerBottom() {
    return _dragPoint(
      top: height - dragPointSize / 2,
      left: width / 2 - dragPointSize / 2,
      onDrag: (dx, dy) {
        cumulativeDy += dy;
        if (cumulativeDy >= stepSize) {
          increase(Side.height);
          cumulativeDy = 0;
          notifyListeners();
        } else if (cumulativeDy <= -stepSize) {
          decrease(Side.height);
          cumulativeDy = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget topLeft() {
    return _dragPoint(
      top: -dragPointSize / 2,
      left: -dragPointSize / 2,
      onDrag: (dx, dy) {
        var mid = (dx + dy) / 2;
        cumulativeMid -= 2 * mid;
        if (cumulativeMid >= stepSize) {
          increase(Side.width, Side.height);
          item.top -= stepSize;
          item.left -= stepSize;
          cumulativeMid = 0;
          notifyListeners();
        } else if (cumulativeMid <= -stepSize) {
          if (left + stepSize <= left + width - minSize) {
            decrease(Side.width, Side.height);
            item.top += stepSize;
            item.left += stepSize;
            cumulativeMid = 0;
            notifyListeners();
          }
        }
      },
    );
  }

  Widget topRight() {
    return _dragPoint(
      top: -dragPointSize / 2,
      left: width - dragPointSize / 2,
      onDrag: (dx, dy) {
        var mid = (dx + (dy * -1)) / 2;
        cumulativeMid += 2 * mid;
        if (cumulativeMid >= stepSize) {
          increase(Side.width, Side.height);
          item.top -= stepSize;
          cumulativeMid = 0;
          notifyListeners();
        } else if (cumulativeMid <= -stepSize) {
          decrease(Side.width, Side.height);
          item.top += stepSize;
          cumulativeMid = 0;
          notifyListeners();
        }
      },
    );
  }

  Widget bottomLeft() {
    return _dragPoint(
      top: height - dragPointSize / 2,
      left: -dragPointSize / 2,
      onDrag: (dx, dy) {
        var mid = ((dx * -1) + dy) / 2;

        cumulativeMid += 2 * mid;
        if (cumulativeMid >= stepSize) {
          increase(Side.width, Side.height);
          item.left -= stepSize;
          cumulativeMid = 0;
          notifyListeners();
        } else if (cumulativeMid <= -stepSize) {
          if (left + stepSize <= left + width - minSize) {
            decrease(Side.width, Side.height);
            item.left += stepSize;
            cumulativeMid = 0;
            notifyListeners();
          }
        }
      },
    );
  }

  Widget bottomRight() {
    return _dragPoint(
      top: height - dragPointSize / 2,
      left: width - dragPointSize / 2,
      onDrag: (dx, dy) {
        var mid = (dx + dy) / 2;
        cumulativeMid += 2 * mid;
        if (cumulativeMid >= stepSize) {
          increase(Side.width, Side.height);
          cumulativeMid = 0;
          notifyListeners();
        } else if (cumulativeMid <= -stepSize) {
          decrease(Side.width, Side.height);
          cumulativeMid = 0;
          notifyListeners();
        }
      },
    );
  }

  ///
  Widget _dragPoint({
    required double top,
    required double left,
    required Function(double, double) onDrag,
  }) {
    if (item.width > 0 && item.height > 0) {
      return Positioned(
        top: top,
        left: left,
        child: DragPoint(onDrag: onDrag),
      );
    }
    return const SizedBox();
  }

  void increase(Side side1, [Side? side2]) {
    if (side1 == Side.width || side2 == Side.width) {
      item.width = setAlLeast((item.width ?? 0) + stepSize);
    }
    if (side1 == Side.height || side2 == Side.height) {
      item.height = setAlLeast((item.height ?? 0) + stepSize);
    }
  }

  void decrease([Side? side1, Side? side2]) {
    if (side1 == Side.width || side2 == Side.width) {
      item.width = setAlLeast((item.width ?? 0) - stepSize);
    }
    if (side1 == Side.height || side2 == Side.height) {
      item.height = setAlLeast((item.height ?? 0) - stepSize);
    }
  }

  double setAlLeast(double value) {
    return value >= minSize ? value : minSize;
  }
}
