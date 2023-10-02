import 'package:flutter/material.dart';

const double dragPointSize = 60.0;
const double haftDragPointSize = dragPointSize/2;
const double dragPointPadding = 24;
const double stepSize = 1;
const double minSize = dragPointSize - dragPointPadding;
enum Side { width, height }


class ResizableContainer extends StatefulWidget {
  final Widget child;
  final BoxDecoration? decoration;
  ResizableContainer({Key? key, required this.child, this.decoration}) : super(key: key);

  @override
  State<ResizableContainer> createState() => _ResizableContainerState();
}

class _ResizableContainerState extends State<ResizableContainer> {
  double height = 400;
  double width = 200;
  double top = 0;
  double left = 0;
  double cumulativeDy = 0;
  double cumulativeDx = 0;
  double cumulativeMid = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: top,
          left: left,
          child: Container(
            height: height,
            width: width,
            decoration: widget.decoration ?? BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 0)
            ),
            child: widget.child,
          ),
        ),

        // CENTER
        DragPoint.positioned(
          top: top + height / 2 - dragPointSize / 2,
          left: left + width / 2 - dragPointSize / 2,
          onDrag: (dx, dy) {
            // top
            // dy -
            //bottom
            // dy +
            cumulativeDy += dy;

            if (cumulativeDy >= stepSize) {
              setState(() {
                top += stepSize;
                cumulativeDy = 0;
              });
            } else if (cumulativeDy <= -stepSize) {
              setState(() {
                top -= stepSize;
                cumulativeDy = 0;
              });
            }
            // left -> -dx
            // right -> +dx
            cumulativeDx += dx;

            if (cumulativeDx >= stepSize) {
              setState(() {
                left += stepSize;
                cumulativeDx = 0;
              });
            } else if (cumulativeDx <= -stepSize) {
              setState(() {
                left -= stepSize;
                cumulativeDx = 0;
              });
            }
          },
        ),

        // CENTER LEFT
        DragPoint.positioned(
          top: top + height / 2 - dragPointSize / 2,
          left: left - dragPointSize / 2,
          onDrag: (dx, dy) {
            cumulativeDx -= dx;
            if (cumulativeDx >= stepSize) {
              setState(() {
                increase(Side.width);
                left = left - stepSize;
                cumulativeDx = 0;
              });
            } else if (cumulativeDx <= -stepSize) {
              if (left + stepSize <= left + width - minSize) {
                setState(() {
                  decrease(Side.width);
                  left = left + stepSize;
                  cumulativeDx = 0;
                });
              }
            }
          },
        ),

        // CENTER RIGHT
        DragPoint.positioned(
          top: top + height / 2 - dragPointSize / 2,
          left: left + width - dragPointSize / 2,
          onDrag: (dx, dy) {
            cumulativeDx += dx;
            if (cumulativeDx >= stepSize) {
              setState(() {
                increase(Side.width);
                cumulativeDx = 0;
              });
            } else if (cumulativeDx <= -stepSize) {
              setState(() {
                decrease(Side.width);
                cumulativeDx = 0;
              });
            }
          },
        ),

        // CENTER TOP
        DragPoint.positioned(
          top: top - dragPointSize / 2,
          left: left + width / 2 - dragPointSize / 2,
          onDrag: (dx, dy) {
            cumulativeDy -= dy;
            if (cumulativeDy >= stepSize) {
              setState(() {
                increase(Side.height);
                top -= stepSize;
                cumulativeDy = 0;
              });
            } else if (cumulativeDy <= -stepSize) {
              setState(() {
                decrease(Side.height);
                top += stepSize;
                cumulativeDy = 0;
              });
            }
          },
        ),

        // CENTER BOTTOM
        DragPoint.positioned(
          top: top + height - dragPointSize / 2,
          left: left + width / 2 - dragPointSize / 2,
          onDrag: (dx, dy) {
            cumulativeDy += dy;

            if (cumulativeDy >= stepSize) {
              setState(() {
                increase(Side.height);
                cumulativeDy = 0;
              });
            } else if (cumulativeDy <= -stepSize) {
              setState(() {
                decrease(Side.height);
                cumulativeDy = 0;
              });
            }
          },
        ),

        // TOP LEFT
        DragPoint.positioned(
          top: top - dragPointSize / 2,
          left: left - dragPointSize / 2,
          onDrag: (dx, dy) {
            var mid = (dx + dy) / 2;
            cumulativeMid -= 2 * mid;
            if (cumulativeMid >= stepSize) {
              setState(() {
                increase(Side.width, Side.height);
                top -= stepSize;
                left -= stepSize;
                cumulativeMid = 0;
              });
            } else if (cumulativeMid <= -stepSize) {
              if (left + stepSize <= left + width - minSize) {
                setState(() {
                  decrease(Side.width, Side.height);
                  top += stepSize;
                  left += stepSize;
                  cumulativeMid = 0;
                });
              }

            }
          },
        ),

        // TOP RIGHT
        DragPoint.positioned(
          top: top - dragPointSize / 2,
          left: left + width - dragPointSize / 2,
          onDrag: (dx, dy) {
            var mid = (dx + (dy * -1)) / 2;
            cumulativeMid += 2 * mid;
            if (cumulativeMid >= stepSize) {
              setState(() {
                increase(Side.width, Side.height);
                top -= stepSize;
                cumulativeMid = 0;
              });
            } else if (cumulativeMid <= -stepSize) {
              setState(() {
                decrease(Side.width, Side.height);
                top += stepSize;
                cumulativeMid = 0;
              });
            }
          },
        ),

        // BOTTOM RIGHT
        DragPoint.positioned(
          top: top + height - dragPointSize / 2,
          left: left + width - dragPointSize / 2,
          onDrag: (dx, dy) {
            var mid = (dx + dy) / 2;
            cumulativeMid += 2 * mid;
            if (cumulativeMid >= stepSize) {
              setState(() {
                increase(Side.width, Side.height);
                cumulativeMid = 0;
              });
            } else if (cumulativeMid <= -stepSize) {
              setState(() {
                decrease(Side.width, Side.height);
                cumulativeMid = 0;
              });
            }
          },
        ),

        // BOTTOM LEFT
        DragPoint.positioned(
          top: top + height - dragPointSize / 2,
          left: left - dragPointSize / 2,
          onDrag: (dx, dy) {
            var mid = ((dx * -1) + dy) / 2;

            cumulativeMid += 2 * mid;
            if (cumulativeMid >= stepSize) {
              setState(() {
                increase(Side.width, Side.height);
                left -= stepSize;
                cumulativeMid = 0;
              });
            } else if (cumulativeMid <= -stepSize) {
              if (left + stepSize <= left + width - minSize) {
                setState(() {
                  decrease(Side.width, Side.height);
                  left += stepSize;
                  cumulativeMid = 0;
                });
              }
            }
          },
        ),
      ],
    );
  }

  void increase(Side side1, [Side? side2]) {
    if (side1 == Side.width || side2 == Side.width) {
      width = setAlLeast(width + stepSize);
    }
    if (side1 == Side.height || side2 == Side.height) {
      height = setAlLeast(height + stepSize);
    }
  }

  void decrease([Side? side1, Side? side2]) {
    if (side1 == Side.width || side2 == Side.width) {
      width = setAlLeast(width - stepSize);
    }
    if (side1 == Side.height || side2 == Side.height) {
      height = setAlLeast(height - stepSize);
    }
  }

  double setAlLeast(double value) {
    return value >= minSize ? value : minSize;
  }
}

class DragPoint extends StatefulWidget {
  final Function onDrag;

  DragPoint({Key? key, required this.onDrag});

  static Widget positioned({
    required double top,
    required double left,
    required Function onDrag,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: DragPoint(
        onDrag: onDrag,
      ),
    );
  }

  @override
  _DragPointState createState() => _DragPointState();
}

class _DragPointState extends State<DragPoint> {
  double? initX;
  double? initY;

  _handleDragStart(details) {
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    // setState(() {});
  }

  _handleDragUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      child: Container(
        color: Colors.transparent,
        width: dragPointSize,
        height: dragPointSize,
        padding: EdgeInsets.all(dragPointPadding),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.amber,
            border: Border.all(width: 2, color: Colors.black),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}