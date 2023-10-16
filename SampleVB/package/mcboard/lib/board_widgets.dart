import 'package:flutter/material.dart';

Widget verticalSeparator({double size = 1, Color? color}) {
  return Container(
    color: color ?? Color(0xFFF2F4F7),
    height: size,
  );
}

Widget get goneBox => const SizedBox(width: 0,height: 0);

Widget horizontalSeparator({double size = 1, Color? color}) {
  return Container(
    color: color ?? Color(0xFFF2F4F7),
    width: size,
  );
}

Widget circleContainer({
  double? size,
  double borderWidth = 0,
  EdgeInsets padding = EdgeInsets.zero,
  Color borderColor = Colors.transparent,
  Color color = Colors.transparent,
  List<BoxShadow>? boxShadow,
  Widget child = const SizedBox(),
}) {
  return decorateContainer(
    width: size,
    height: size,
    radius: (size ?? 0) / 2,
    borderWidth: borderWidth,
    padding: padding,
    borderColor: borderColor,
    boxShadow: boxShadow,
    color: color,
    child: child,
  );
}

Widget squareContainer({
  double? size,
  double radius = 0,
  double borderWidth = 0,
  EdgeInsets padding = EdgeInsets.zero,
  Color borderColor = Colors.transparent,
  Color color = Colors.transparent,
  Widget child = const SizedBox(),
  List<BoxShadow>? boxShadow,
}) {
  return decorateContainer(
    width: size,
    height: size,
    radius: radius,
    borderWidth: borderWidth,
    padding: padding,
    borderColor: borderColor,
    boxShadow: boxShadow,
    color: color,
    child: child,
  );
}

Widget decorateContainer({
  double? width,
  double? height,
  double? radius,
  double? topRadius,
  double? topLeftRadius,
  double? topRightRadius,
  double? bottomLeftRadius,
  double? bottomRightRadius,
  double? bottomRadius,
  double borderWidth = 0,
  EdgeInsets padding = EdgeInsets.zero,
  Color borderColor = Colors.transparent,
  Color color = Colors.transparent,
  Widget child = const SizedBox(),
  List<BoxShadow>? boxShadow,
}) {
  return Container(
    padding: padding,
    width: width,
    height: height,
    decoration: BoxDecoration(
      border: Border.all(
        width: borderWidth,
        color: borderColor,
      ),
      color: color,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeftRadius ?? topRadius ?? radius ?? 0),
        topRight: Radius.circular(topRightRadius ?? topRadius ?? radius ?? 0),
        bottomLeft: Radius.circular(bottomLeftRadius ?? bottomRadius ?? radius ?? 0),
        bottomRight: Radius.circular(bottomRightRadius ?? bottomRadius ?? radius ?? 0),
      ),
      boxShadow: boxShadow,
    ),
    child: child,
  );
}

Widget container({
  double? width,
  double? height,
  double? padding,
  double? paddingLeft,
  double? paddingTop,
  double? paddingRight,
  double? paddingVertical,
  double? paddingHorizontal,
  double? paddingBottom,
  Decoration? decoration,
  Widget? child,
}) {
  return Container(
    padding: EdgeInsets.only(
      left: paddingLeft ?? paddingHorizontal ?? padding ?? 0,
      right: paddingRight ?? paddingHorizontal ?? padding ?? 0,
      top: paddingTop ?? paddingVertical ?? padding ?? 0,
      bottom: paddingBottom ?? paddingVertical ?? padding ?? 0,
    ),
    decoration: decoration,
    width: width,
    height: height,
    child: child,
  );
}