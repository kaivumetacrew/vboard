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
      double scale = widget.width! / 100;
      return Container(
        color: Colors.red,
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
          color: Colors.blue,
        ),
      );
    }
    if (widget.width == null && widget.height != null) {
      return measureContainer(
        Container(
          height: widget.height,
          color: Colors.green,
        ),
      );
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.amber,
    );
  }

  Widget child() {
    return Wrap(
      children: [
        Container(
          width: 100,
          height: 100,
          color: Colors.black,
        )
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
            await Future.delayed(const Duration(seconds: 3));
            setState(() {});
            //widget.onSizeChanged();
          }
        },
        child: child,
      ),
    );
  }
}
