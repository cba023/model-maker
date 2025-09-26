import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';

class CodeTextFieldWrapper extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final Function(String)? onChanged;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const CodeTextFieldWrapper({
    Key? key,
    required this.controller,
    this.hintText = '',
    this.readOnly = false,
    this.onChanged,
    this.textStyle,
    this.hintStyle,
  }) : super(key: key);

  @override
  State<CodeTextFieldWrapper> createState() => _CodeTextFieldWrapperState();
}

class _CodeTextFieldWrapperState extends State<CodeTextFieldWrapper> {
  late CodeController _codeController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // 初始化 CodeController
    _codeController = CodeController(
      text: widget.controller.text,
      language: null, // 不指定语言，使用纯文本模式
    );

    // 监听文本变化
    _codeController.addListener(() {
      widget.controller.text = _codeController.text;
      widget.onChanged?.call(_codeController.text);
    });

    // 监听外部控制器变化
    widget.controller.addListener(() {
      if (widget.controller.text != _codeController.text) {
        _codeController.text = widget.controller.text;
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CodeField(
        controller: _codeController,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        lineNumberStyle: LineNumberStyle(
          textStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontFamily: 'monospace',
          ),
          width: 50,
          margin: 8,
        ),
        textStyle:
            widget.textStyle ??
            TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Colors.black87, // 更深的正文颜色
            ),
        background: Colors.white,
        cursorColor: Colors.blue,
        horizontalScroll: true,
        wrap: false, // 关闭软换行
        expands: true,
      ),
    );
  }
}
