import 'package:flutter/material.dart';
import 'package:mcboard/board.dart';

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: EdgeInsets.all(0),
        child: ResizableContainer(
          child: Center(
            child: Container(
              color: Colors.amber,
            ),
          ),
        ),
      ),
    );
  }
}

