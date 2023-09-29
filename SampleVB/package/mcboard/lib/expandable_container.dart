import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpandableContainer extends StatefulWidget {
  Widget header;
  Widget expand;
  Decoration? decoration;

  ExpandableContainer({
    super.key,
    required this.header,
    required this.expand,
  });

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  late Size size;
  bool isExpanded = false;
  double? currentHeight = 0;
  double? currentWidth = 0;
  double? expandWidth;
  double? expandHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    Widget expandWidget;

    if (expandHeight == null) {
      expandWidget = MeasureSize(
        onChange: (Size size) {
          expandWidth = size.width;
          expandHeight = size.height;
          setState(() {});
        },
        child: widget.expand,
      );
    } else {
      int duration = expandHeight!.round();
      if (duration >= 300) duration = 300;
      expandWidget = AnimatedContainer(
        duration: Duration(milliseconds: duration),
        height: currentHeight,
        width: size.width,
        decoration: widget.decoration,
        child: widget.expand,
      );
    }
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              isExpanded = !isExpanded;
              onExpandOrCollapse();
            },
            child: widget.header,
          ),
          expandWidget,
        ],
      ),
    );
  }

  void onExpandOrCollapse() {
    if (isExpanded) {
      currentHeight = expandHeight;
    } else {
      currentHeight = 0;
    }
    setState(() {});
  }
}

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}
