import 'package:flutter/material.dart';

import 'board_config.dart';
import 'expandable_container.dart';

class BoardContainer extends StatefulWidget {
  double? width;
  double? height;
  Widget child;

  BoardContainer({
    Key? key,
    this.width,
    this.height,
    required this.child,
  }) : super(key: key);

  @override
  State createState() => _BoardContainerState();
}

class _BoardContainerState extends State<BoardContainer> {


  @override
  Widget build(BuildContext context) {
    if (widget.width != null && widget.height != null) {
      double scale = widget.width! / BoardConfigs.widthDip;
      return Container(
        color: Colors.transparent,
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: child(),
          ),
        ),
      );
    }
    if (widget.width != null && widget.height == null) {
      return measureContainer(
        Container(
          width: widget.width,
          color: Colors.transparent,
        ),
      );
    }
    if (widget.width == null && widget.height != null) {
      return measureContainer(
        Container(
          height: widget.height,
          color: Colors.transparent,
        ),
      );
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.transparent,
    );
  }

  Widget child() {
    return Wrap(
      children: [
        widget.child
      ],
    );
  }

  Widget measureContainer(Widget child) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: MeasureSize(
        onChange: (Size size) async {
          if (size.width > 0 && size.height > 0) {
            widget.width = size.width;
            widget.height = size.height;
            setState(() {});
            //widget.onSizeChanged();
          }
        },
        child: child,
      ),
    );
  }
}
