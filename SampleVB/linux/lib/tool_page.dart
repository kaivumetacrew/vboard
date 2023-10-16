import 'package:flutter/material.dart';
import 'package:mcboard/board.dart';

class ToolPage extends StatefulWidget {

  BoardController controller;

  ToolPage({super.key, required this.controller});

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {

  BoardController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child:Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(width: 1, color: Colors.grey)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_rounded),
                    onPressed: () {
                      controller.pickImage();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_fields),
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onTabItemTap(int value) {}
}
