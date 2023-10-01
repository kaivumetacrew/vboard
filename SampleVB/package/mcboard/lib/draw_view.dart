import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'board_point.dart';
import 'draw_controller.dart';

/// draw canvas. Controller is required, other parameters are optional.
/// widget/canvas expands to maximum by default.
/// this behaviour can be overridden using width and/or height parameters.
class DrawView extends StatefulWidget {
  /// constructor
  const DrawView({
    required this.controller,
    Key? key,
    this.backgroundColor = Colors.transparent,
    this.dynamicPressureSupported = false,
    this.width,
    this.height,
  }) : super(key: key);

  /// draw widget controller
  final DrawController controller;

  /// draw widget width
  final double? width;

  /// draw widget height
  final double? height;

  /// draw widget background color
  final Color backgroundColor;

  /// support dynamic pressure for width (if has support for it)
  final bool dynamicPressureSupported;

  @override
  State createState() => DrawViewState();
}

/// draw widget state
class DrawViewState extends State<DrawView> {
  /// Helper variable indicating that user has left the canvas so we can prevent linking next point
  /// with straight line.
  bool _isOutsideDrawField = false;

  /// Active pointer to prevent multitouch drawing
  int? activePointerId;

  /// Real widget size
  Size? screenSize;

  /// Max width of canvas
  late double maxWidth;

  /// Max height of canvas
  late double maxHeight;

  @override
  void initState() {
    super.initState();
    _updateWidgetSize();
  }

  @override
  Widget build(BuildContext context) {
    final GestureDetector drawCanvas = GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        //NO-OP
      },
      child: Container(
        color: widget.backgroundColor,
        child: Listener(
            onPointerDown: (PointerDownEvent event) {
              if (!widget.controller.disabled &&
                  (activePointerId == null ||
                      activePointerId == event.pointer)) {
                activePointerId = event.pointer;
                widget.controller.onDrawStart?.call();
                _addPoint(event, BoardPointType.tap);
              }
            },
            onPointerUp: (PointerUpEvent event) {
              _ensurePointerCleanup();
              if (activePointerId == event.pointer) {
                _addPoint(event, BoardPointType.tap);
                widget.controller.pushCurrentStateToUndoStack();
                widget.controller.onDrawEnd?.call();
                activePointerId = null;
              }
            },
            onPointerCancel: (PointerCancelEvent event) {
              _ensurePointerCleanup();
              if (activePointerId == event.pointer) {
                _addPoint(event, BoardPointType.tap);
                widget.controller.pushCurrentStateToUndoStack();
                widget.controller.onDrawEnd?.call();
                activePointerId = null;
              }
            },
            onPointerMove: (PointerMoveEvent event) {
              _ensurePointerCleanup();
              if (activePointerId == event.pointer) {
                _addPoint(event, BoardPointType.move);
                widget.controller.onDrawMove?.call();
              }
            },
            child: RepaintBoundary(
              child: CustomPaint(
                painter: DrawPainter(widget.controller),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: maxWidth,
                      minHeight: maxHeight,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight),
                ),
              ),
            )),
      ),
    );

    if (widget.width != null || widget.height != null) {
      //IF DOUNDARIES ARE DEFINED, USE LIMITED BOX
      return Center(
        child: LimitedBox(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          child: drawCanvas,
        ),
      );
    } else {
      //IF NO BOUNDARIES ARE DEFINED, RETURN THE WIDGET AS IS
      return drawCanvas;
    }
  }

  @override
  void didUpdateWidget(covariant DrawView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateWidgetSize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  void _addPoint(PointerEvent event, int pointType) {
    final Offset o = event.localPosition;

    // IF WIDGET IS USED WITHOUT DIMENSIONS, WE WILL FALLBACK TO SCREENSIZE
    // DIMENSIONS
    final double _maxSafeWidth =
    maxWidth == double.infinity ? screenSize!.width : maxWidth;
    final double _maxSafeHeight =
    maxHeight == double.infinity ? screenSize!.height : maxHeight;

    //SAVE POINT ONLY IF IT IS IN THE SPECIFIED BOUNDARIES
    if ((screenSize?.width == null || o.dx > 0 && o.dx < _maxSafeWidth) &&
        (screenSize?.height == null || o.dy > 0 && o.dy < _maxSafeHeight)) {
      // IF USER LEFT THE BOUNDARY AND ALSO RETURNED BACK
      // IN ONE MOVE, RETYPE IT AS TAP, AS WE DO NOT WANT TO
      // LINK IT WITH PREVIOUS POINT
      int t = pointType;
      if (_isOutsideDrawField) {
        t = BoardPointType.tap;
      }
      setState(() {
        //IF USER WAS OUTSIDE OF CANVAS WE WILL RESET THE HELPER VARIABLE AS HE HAS RETURNED
        _isOutsideDrawField = false;
        widget.controller.addPoint(BoardPoint(
          o,
          t,
          widget.dynamicPressureSupported ? event.pressure : 1.0,
        ));
      });
    } else {
      //NOTE: USER LEFT THE CANVAS!!! WE WILL SET HELPER VARIABLE
      //WE ARE NOT UPDATING IN setState METHOD BECAUSE WE DO NOT NEED TO RUN BUILD METHOD
      _isOutsideDrawField = true;
    }
  }

  void _updateWidgetSize() {
    maxWidth = widget.width ?? double.infinity;
    maxHeight = widget.height ?? double.infinity;
  }

  /// METHOD THAT WILL CLEANUP ANY REMNANT POINTER AFTER DISABLING
  /// WIDGET
  void _ensurePointerCleanup() {
    if (widget.controller.disabled && activePointerId != null) {
      // WIDGET HAS BEEN DISABLED DURING DRAWING.
      // CANCEL CURRENT DRAW
      activePointerId = null;
    }
  }
}

class DrawPainter extends CustomPainter {
  DrawPainter(this._controller, {Color? penColor})
      : _penStyle = Paint(),
        super(repaint: _controller) {
    _penStyle
      ..color = penColor ?? _controller.penColor
      ..strokeWidth = _controller.penStrokeWidth;
    //..strokeCap = _controller.strokeCap
    //..strokeJoin = _controller.strokeJoin;
  }

  final DrawController _controller;
  final Paint _penStyle;

  @override
  void paint(Canvas canvas, _) {
    final List<BoardPoint> points = _controller.value;
    if (points.isEmpty) {
      return;
    }
    for (int i = 0; i < (points.length - 1); i++) {
      if (points[i + 1].type == BoardPointType.move) {
        _penStyle.strokeWidth *= points[i].pressure;
        canvas.drawLine(
          points[i].offset,
          points[i + 1].offset,
          _penStyle,
        );
      } else {
        canvas.drawCircle(
          points[i].offset,
          (_penStyle.strokeWidth / 2) * points[i].pressure,
          _penStyle,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
