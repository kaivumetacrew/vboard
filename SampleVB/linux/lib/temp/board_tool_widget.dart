import 'package:flutter/material.dart';
import 'package:samplevb/textfield.dart';

mixin BoardTool {
  static double rowHeight = 40;
  static double editHeight = 30;
  static double editWidth = 40;
  static double rowRadius = 4;
}

mixin BoardToolMixin {
  Widget get sessionMargin => const SizedBox(width: 4, height: 4);

  BoxDecoration sessionDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(BoardTool.rowRadius)),
      border: Border.all(
        color: Colors.grey,
        width: 1,
      ),
    );
  }

  Widget sessionEditText(String text, Function(dynamic)? onTap) {
    return Row(
      children: [
        childButton(text, null),
        const Expanded(child: SizedBox()),
        AppTextField(
          controller: AppTextController(),
          maxLength: 2,
          width: BoardTool.editWidth,
          height: BoardTool.editHeight,
        ),
      ],
    );
  }

  Widget sessionIcon(String text, IconData icon, Function(dynamic)? onTap) {
    return Row(
      children: [
        childButton(text, null),
        const Expanded(child: SizedBox()),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.all(4),
            width: BoardTool.editWidth,
            height: BoardTool.editHeight,
            decoration: sessionDecoration(),
            child: Center(
              child: Icon(icon, size: 20),
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }

  Widget sessionContainer({
    bool border = false,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(BoardTool.rowRadius),
      height: BoardTool.rowHeight,
      decoration: sessionDecoration(),
      child: Center(
        child: child,
      ),
    );
  }

  Widget childButton(
    String text,
    Function()? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        height: BoardTool.rowHeight,
        child: Text(text, style: const TextStyle(fontSize: 13),),
      ),
    );
  }

  Widget sessionButton({
    required String title,
    List<Widget>? children,
  }) {
    return SessionButton(
      decoration: sessionDecoration(),
      sessionPadding: 4,
      contentPadding: 8,
      header: sessionContainer(
        child: Center(
          child: Text(title),
        ),
      ),
      children: children,
    );
  }

  Widget childSessionButton({
    required String title,
    double? height,
    List<Widget>? children,
  }) {
    return SessionButton(
      sessionPadding: 0,
      header: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        height: BoardTool.rowHeight,
        child: Text(title, style: const TextStyle(fontSize: 13),),
      ),
      children: children,
    );
  }
}

class SessionButton extends StatefulWidget {
  Widget header;
  List<Widget>? children;
  double? sessionPadding;
  double? contentPadding;
  Decoration? decoration;
  double currentHeight = 0;

  SessionButton({
    super.key,
    required this.header,
    this.children,
    this.sessionPadding,
    this.contentPadding,
    this.decoration,
  });

  @override
  State<SessionButton> createState() => _SessionButtonState();
}

class _SessionButtonState extends State<SessionButton> {
  late Size size;
  bool isExpanded = false;
  State<SessionButton>? parentState;

  @override
  void initState() {
    super.initState();
    widget.children?.forEach((element) {
      if (element is SessionButton) {
        parentState = this;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              isExpanded = !isExpanded;
              onExpandOrCollapse();
            },
            child: widget.header,
          ),
          SizedBox(height: widget.sessionPadding ?? 0),
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            height: widget.currentHeight,
            width: size.width,
            decoration: widget.decoration,
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: widget.contentPadding ?? 0,
              ),
              children: widget.children ?? [],
            ),
          )
        ],
      ),
    );
  }

  void onExpandOrCollapse() {
    if (isExpanded) {
      double height = 0;
      height += (widget.children?.length ?? 0) * BoardTool.rowHeight;
      widget.children?.forEach((element) {
        if (element is SessionButton) {
          height += element.currentHeight;
        }
      });
      widget.currentHeight = height;
    } else {
      widget.currentHeight = 0;
    }
    if (parentState == null) {
      setState(() {});
    }
    parentState?.setState(() {});
  }
}
