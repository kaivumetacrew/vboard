import 'dart:ui';

/// one point on canvas represented by offset and type
class BoardPoint {
  /// constructor
  BoardPoint(this.offset, this.type, this.pressure);

  /// x and y value on 2D canvas
  Offset offset;

  /// pressure that user applied
  double pressure;

  /// type of user display finger movement
  int type;

  Map<String, dynamic> toJson() => {
    'x': offset.dx,
    'y': offset.dy,
    'pressure': pressure,
    'type': type,
  };

  static BoardPoint fromJson(Map<String, dynamic> json) {
    Offset offset = Offset(json['x'], json['y']);
    double pressure = json['pressure'];
    int type = json['type'];
    return BoardPoint(offset, type, pressure);
  }
}

/// type of user display finger movement
class BoardPointType {
  /// one touch on specific place - tap
  static int tap = 1;

  /// finger touching the display and moving around
  static int move = 2;
}