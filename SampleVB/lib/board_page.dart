import 'package:flutter/material.dart';
import 'package:mcboard/board.dart';
import 'package:samplevb/tool_page.dart';

class BoardPage extends StatefulWidget {
  BoardPage({super.key});

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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: BoardView(
                width: double.infinity,
                controller: boardController,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(width: 1, color: Colors.grey)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ToolPage(controller: boardController);
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
