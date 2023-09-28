import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextController {
  late TextEditingController editController;

  Function(String)? onSubmit;
  Function(State, String)? onChanged;
  Function()? onTap;

  AppTextController({
    String? text,
    this.onSubmit,
    this.onChanged,
    this.onTap,
  }) {
    editController = TextEditingController(text: text);
  }

  void onInitState(State state) {
  }

  void onDispose() {
    editController.dispose();
  }

  String? get text => editController.text;

  bool get textNotEmpty => text != null && text!.isNotEmpty;

  bool get textIsEmpty => !textNotEmpty;

  set text(String? s) {
    editController.text = s ?? "";
  }

  ValueNotifier<String?> errorValueNotifier = ValueNotifier(null);

  bool get hasError => errorValueNotifier.value != null;

  set error(String? s) {
    errorValueNotifier.value = s;
  }
}

class AppTextField extends StatefulWidget {
  final TextInputType? textInputType;

  final TextInputAction? textInputAction;

  final int? maxLines;
  final double height;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final AppTextController controller;
  final double width;

  AppTextField({
    Key? key,
    required this.controller,
    this.textInputType,
    this.maxLines,
    this.height = 40,
    this.textInputAction,
    this.maxLength,
    this.width = double.infinity,
    this.inputFormatters,
  }) : super(key: key) {

  }

  @override
  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  AppTextController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.onInitState(this);
  }

  @override
  void dispose() {
    _controller.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      child: textFormField(),
    );
  }


  TextStyle textStyle() {
    return  TextStyle(
      fontSize: 13,

    );
  }

  Widget textFormField() {
    return TextFormField(
      controller: _controller.editController,
      keyboardType: widget.textInputType ?? TextInputType.text,
      onFieldSubmitted: _controller.onSubmit,
      onChanged: (text) {
        _controller.onChanged?.call(this, text);
      },
      style: textStyle(),
      textAlign: TextAlign.center,
      textInputAction: widget.textInputAction,
      textAlignVertical: TextAlignVertical.center,
      onTap: _controller.onTap,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      decoration: const InputDecoration(
        counterText: "",
        isCollapsed: true,
        contentPadding: EdgeInsets.all(8),
        border: InputBorder.none,
      ),
    );
  }
}
