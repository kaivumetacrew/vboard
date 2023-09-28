import 'package:flutter/material.dart';
import 'package:mcboard/board.dart';
import 'package:samplevb/board_toolbar.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  BoardController boardController = BoardController(BoardData(
    id: 1,
    name: "untitle",
    backgroundColor: "#EAECF0",
    borderColor: "#344054",
    borderWidth: 2,
    borderRadius: 14,
    items: [],
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Sample board"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child:   Row(
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: BoardView(controller: boardController),
              ),
              const Padding(padding: EdgeInsets.only(left: 8)),
              Expanded(
                child: BoardToolBar(),
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
