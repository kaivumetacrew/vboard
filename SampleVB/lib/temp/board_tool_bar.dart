import 'package:flutter/material.dart';
import 'package:samplevb/textfield.dart';
import 'package:mcboard/board.dart';
import 'board_tool_widget.dart';

class BoardToolBar extends StatefulWidget {

  BoardController controller;

  BoardToolBar({super.key,required this.controller});

  @override
  State<BoardToolBar> createState() => _BoardToolBarState();
}



class _BoardToolBarState extends State<BoardToolBar> with BoardToolMixin {

  AppTextController borderWidthCtr = AppTextController();

  BoardController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        sessionButton(
          title: "Board",
          children: [
            childButton("Background", () {}),
            childSessionButton(
              title: "Border",
              children: [
                sessionEditText("Width", (p0) => null),
                sessionEditText("Radius", (p0) => null),
                sessionIcon("Lines", Icons.ac_unit, (p0) => null)
              ],
            ),
          ],
        ),
        sessionMargin,
        sessionButton(
          title: "Add",
          children: [
            childButton("Text", () {

            }),
            childButton("Image", () {
              controller.pickImage();
            }),
          ],
        )
      ],
    );
  }
}

