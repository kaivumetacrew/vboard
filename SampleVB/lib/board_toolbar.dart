import 'package:flutter/material.dart';
import 'package:samplevb/textfield.dart';

class BoardToolBar extends StatefulWidget {
  BoardToolBar({super.key});

  @override
  State<BoardToolBar> createState() => _BoardToolBarState();
}

class _BoardToolBarState extends State<BoardToolBar> {
  AppTextController borderWidthCtr = AppTextController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        sessionButton(
          title: "Board",
          children: [
            _childButton("Background", () {}),
            childSessionButton(
              title: "Border",
              children: [
                _sessionEditText("Width", (p0) => null),
                _sessionEditText("Radius", (p0) => null),
                _sessionIcon("Lines", Icons.ac_unit, (p0) => null)
              ],
            ),
          ],
        ),
        _sessionMargin,
        sessionButton(
          title: "Add",
          children: [
            _childButton("Text", () {

            }),
            _childButton("Image", () {

            }),
          ],
        )
      ],
    );
  }
}

mixin SessionButtonMixin {}

Widget sessionButton({
  required String title,
  List<Widget>? children,
}) {
  return SessionButton(
    border: true,
    sessionPadding: 4,
    contentPadding: 8,
    header: _sessionContainer(
      border: true,
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
    border: false,
    sessionPadding: 0,
    header: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      height: _rowHeight,
      child: Text(title, style: _buttonStyle),
    ),
    children: children,
  );
}

double _rowHeight = 40;

double _editHeight = 30;

double _editWidth = 40;

double _rowRadius = 4;

Widget get _sessionMargin => const SizedBox(width: 4, height: 4);

TextStyle get _buttonStyle => const TextStyle(fontSize: 13);

BoxDecoration _sessionDecoration({bool border = false}) {
  return BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(_rowRadius)),
    border: Border.all(
      color: border ? Colors.grey : Colors.transparent,
      width: border ? 1 : 0,
    ),
  );
}

Widget _sessionEditText(String text, Function(dynamic)? onTap) {
  return Row(
    children: [
      _childButton(text, null),
      const Expanded(child: SizedBox()),
      AppTextField(
        controller: AppTextController(),
        maxLength: 2,
        width: _editWidth,
        height: _editHeight,
      ),
    ],
  );
}

Widget _sessionIcon(String text, IconData icon, Function(dynamic)? onTap) {
  return Row(
    children: [
      _childButton(text, null),
      const Expanded(child: SizedBox()),
      GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(4),
          width: _editWidth,
          height: _editHeight,
          decoration: _sessionDecoration(border: true),
          child: Center(
            child: Icon(icon, size: 20),
          ),
        ),
        onTap: () {},
      ),
    ],
  );
}

Widget _sessionContainer({
  bool border = false,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(4),
    height: _rowHeight,
    decoration: _sessionDecoration(border: border),
    child: Center(
      child: child,
    ),
  );
}

Widget _childButton(
  String text,
  Function()? onTap,
) {
  return GestureDetector(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      height: _rowHeight,
      child: Text(text, style: _buttonStyle),
    ),
    onTap: onTap,
  );
}

class SessionButton extends StatefulWidget {
  Widget header;
  List<Widget>? children;
  double? sessionPadding;
  double? contentPadding;
  bool border;
  late Size size;
  double currentHeight = 0;
  bool isExpanded = false;
  State<SessionButton>? parentState;

  SessionButton({
    super.key,
    required this.header,
    this.children,
    this.sessionPadding,
    this.contentPadding,
    this.border = true,
  });

  @override
  State<SessionButton> createState() => _SessionButtonState();
}

class _SessionButtonState extends State<SessionButton> with SessionButtonMixin {
  @override
  void initState() {
    super.initState();
    widget.children?.forEach((element) {
      if (element is SessionButton) {
        element.parentState = this;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.size = MediaQuery.of(context).size;
    return SizedBox(
      width: widget.size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              widget.isExpanded = !widget.isExpanded;
              onExpandOrCollapse();
            },
            child: widget.header,
          ),
          SizedBox(height: widget.sessionPadding ?? 0),
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            height: widget.currentHeight,
            width: widget.size.width,
            decoration: _sessionDecoration(border: widget.border),
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
    if (widget.isExpanded) {
      double height = 0;
      height += (widget.children?.length ?? 0) * _rowHeight;
      widget.children?.forEach((element) {
        if (element is SessionButton) {
          height += element.currentHeight;
        }
      });
      widget.currentHeight = height;
    } else {
      widget.currentHeight = 0;
    }

    final parentState = widget.parentState;
    if (parentState == null) {
      setState(() {});
    }
    widget.parentState?.setState(() {});
  }


}
