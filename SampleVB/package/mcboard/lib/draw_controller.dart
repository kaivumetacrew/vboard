import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'board_point.dart';

class DrawController extends ValueNotifier<List<BoardPoint>> {
  /// constructor
  DrawController({
    List<BoardPoint>? points,
    this.disabled = false,
    this.penColor = Colors.black,
    this.strokeCap = StrokeCap.butt,
    this.strokeJoin = StrokeJoin.miter,
    this.penStrokeWidth = 3,
    this.exportBackgroundColor,
    this.exportPenColor,
    this.onDrawStart,
    this.onDrawMove,
    this.onDrawEnd,
  }) : super(points ?? <BoardPoint>[]);

  /// If set to true canvas writting will be disabled.
  bool disabled;

  /// color of a draw line
  Color penColor;

  /// boldness of a draw line
  final double penStrokeWidth;

  /// shape of line ends
  final StrokeCap strokeCap;

  /// shape of line joins
  final StrokeJoin strokeJoin;

  /// background color to be used in exported png image
  final Color? exportBackgroundColor;

  /// color of a draw line to be used in exported png image
  final Color? exportPenColor;

  /// callback to notify when drawing has started
  VoidCallback? onDrawStart;

  /// callback to notify when the pointer was moved while drawing.
  VoidCallback? onDrawMove;

  /// callback to notify when drawing has stopped
  VoidCallback? onDrawEnd;

  /// getter for points representing draw on 2D canvas
  List<BoardPoint> get points => value;

  /// stack-like list of point to save user's latest action
  final List<List<BoardPoint>> _latestActions = <List<BoardPoint>>[];

  /// stack-like list that use to save points when user undo the draw
  final List<List<BoardPoint>> _revertedActions = <List<BoardPoint>>[];

  /// setter for points representing draw on 2D canvas
  set points(List<BoardPoint> points) {
    value = points;
  }

  /// add point to point collection
  void addPoint(BoardPoint point) {
    value.add(point);
    notifyListeners();
  }

  /// REMEMBERS CURRENT CANVAS STATE IN UNDO STACK
  void pushCurrentStateToUndoStack() {
    _latestActions.add(<BoardPoint>[...points]);
    //CLEAR ANY UNDO-ED ACTIONS. IF USER UNDO-ED ANYTHING HE ALREADY MADE
    // ANOTHER CHANGE AND LEFT THAT OLD PATH.
    _revertedActions.clear();
  }

  /// check if canvas is empty (opposite of isNotEmpty method for convenience)
  bool get isEmpty => value.isEmpty;

  /// check if canvas is not empty (opposite of isEmpty method for convenience)
  bool get isNotEmpty => value.isNotEmpty;

  /// The biggest x value for all points.
  /// Will return `null` if there are no points.
  double? get maxXValue =>
      isEmpty ? null : points.map((BoardPoint p) => p.offset.dx).reduce(math.max);

  /// The biggest y value for all points.
  /// Will return `null` if there are no points.
  double? get maxYValue =>
      isEmpty ? null : points.map((BoardPoint p) => p.offset.dy).reduce(math.max);

  /// The smallest x value for all points.
  /// Will return `null` if there are no points.
  double? get minXValue =>
      isEmpty ? null : points.map((BoardPoint p) => p.offset.dx).reduce(math.min);

  /// The smallest y value for all points.
  /// Will return `null` if there are no points.
  double? get minYValue =>
      isEmpty ? null : points.map((BoardPoint p) => p.offset.dy).reduce(math.min);

  /// Calculates a default height based on existing points.
  /// Will return `null` if there are no points.
  int? get defaultHeight =>
      isEmpty ? null : (maxYValue! - minYValue! + penStrokeWidth * 2).toInt();

  /// Calculates a default width based on existing points.
  /// Will return `null` if there are no points.
  int? get defaultWidth =>
      isEmpty ? null : (maxXValue! - minXValue! + penStrokeWidth * 2).toInt();

  /// Calculates a default width based on existing points.
  /// Will return `null` if there are no points.
  List<BoardPoint>? _translatePoints(List<BoardPoint> points) => isEmpty
      ? null
      : points
      .map((BoardPoint p) => BoardPoint(
      Offset(
        p.offset.dx - minXValue! + penStrokeWidth,
        p.offset.dy - minYValue! + penStrokeWidth,
      ),
      p.type,
      p.pressure))
      .toList();

  /// Clear the canvas
  void clear() {
    value = <BoardPoint>[];
    _latestActions.clear();
    _revertedActions.clear();
  }

  /// It will remove last action from [_latestActions].
  /// The last action will be saved to [_revertedActions]
  /// that will be used to do redo-ing.
  /// Then, it will modify the real points with the last action.
  void undo() {
    if (_latestActions.isNotEmpty) {
      final List<BoardPoint> lastAction = _latestActions.removeLast();
      _revertedActions.add(<BoardPoint>[...lastAction]);
      if (_latestActions.isNotEmpty) {
        points = <BoardPoint>[..._latestActions.last];
        return;
      }
      points = <BoardPoint>[];
      notifyListeners();
    }
  }

  /// It will remove last reverted actions and add it into [_latestActions]
  /// Then, it will modify the real points with the last reverted action.
  void redo() {
    if (_revertedActions.isNotEmpty) {
      final List<BoardPoint> lastRevertedAction = _revertedActions.removeLast();
      _latestActions.add(<BoardPoint>[...lastRevertedAction]);
      points = <BoardPoint>[...lastRevertedAction];
      notifyListeners();
      return;
    }
  }

  /// 'image.toByteData' is not available for web. So we are using the package
  /// 'image' to create an image which works on web too.
  /// Will return `null` if there are no points.
  Uint8List? _toPngBytesForWeb({int? height, int? width}) {
    if (isEmpty) {
      return null;
    }

    if (width != null || height != null) {
      assert(
      ((width ?? defaultWidth!) - defaultWidth!) >= 0.0,
      'Exported width cannot be smaller than actual width',
      );
      assert(
      ((height ?? defaultHeight!) - defaultHeight!) >= 0.0,
      'Exported height cannot be smaller than actual height',
      );
    }

    final int pColor = img.Color.fromRgb(
      exportPenColor?.red ?? penColor.red,
      exportPenColor?.green ?? penColor.green,
      exportPenColor?.blue ?? penColor.blue,
    );

    final Color backgroundColor = exportBackgroundColor ?? Colors.transparent;
    final int bColor = img.Color.fromRgba(
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
      backgroundColor.alpha.toInt(),
    );

    final List<BoardPoint> translatedPoints = _translatePoints(points)!;

    final int canvasWidth = width ?? defaultWidth!;
    final int canvasHeight = height ?? defaultHeight!;

    // create the image with the given size
    final img.Image drawImage = img.Image(
      canvasWidth,
      canvasHeight,
      channels: img.Channels.rgba,
    );
    // set the image background color
    img.fill(drawImage, bColor);

    final double xOffset =
        ((width ?? defaultWidth!) - defaultWidth!).toDouble() / 2;
    final double yOffset =
        ((height ?? defaultHeight!) - defaultHeight!).toDouble() / 2;

    // read the drawing points list and draw the image
    // it uses the same logic as the CustomPainter Paint function
    for (int i = 0; i < translatedPoints.length - 1; i++) {
      if (translatedPoints[i + 1].type == BoardPointType.move) {
        img.drawLine(
          drawImage,
          (translatedPoints[i].offset.dx + xOffset).toInt(),
          (translatedPoints[i].offset.dy + yOffset).toInt(),
          (translatedPoints[i + 1].offset.dx + xOffset).toInt(),
          (translatedPoints[i + 1].offset.dy + yOffset).toInt(),
          pColor,
          thickness: penStrokeWidth,
        );
      } else {
        // draw the point to the image
        img.fillCircle(
          drawImage,
          (translatedPoints[i].offset.dx + xOffset).toInt(),
          (translatedPoints[i].offset.dy + yOffset).toInt(),
          penStrokeWidth.toInt(),
          pColor,
        );
      }
    }
    // encode the image to PNG
    return Uint8List.fromList(img.encodePng(drawImage));
  }

  /// Export the current content to a raw SVG string.
  /// Will return `null` if there are no points.
  String? toRawSVG({int? width, int? height}) {
    if (isEmpty) {
      return null;
    }

    String colorToHex(Color c) =>
        '#${c.value.toRadixString(16).padLeft(8, '0')}';

    String formatPoint(BoardPoint p) =>
        '${p.offset.dx.toStringAsFixed(2)},${p.offset.dy.toStringAsFixed(2)}';

    final String polyLines = <String>[
      for (final List<BoardPoint> stroke in _latestActions)
        '<polyline '
            'fill="none" '
            'stroke="${colorToHex(penColor)}" '
            'points="${_translatePoints(stroke)!.map(formatPoint).join(' ')}" '
            '/>'
    ].join('\n');

    width ??= defaultWidth;
    height ??= defaultHeight;

    return '<svg '
        'viewBox="0 0 $width $height" '
        'xmlns="http://www.w3.org/2000/svg"'
        '>\n$polyLines\n</svg>';
  }
}