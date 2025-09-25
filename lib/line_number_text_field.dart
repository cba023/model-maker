import 'package:flutter/material.dart';

class LineNumberTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final Function(String)? onChanged;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const LineNumberTextField({
    Key? key,
    required this.controller,
    this.hintText = '',
    this.readOnly = false,
    this.onChanged,
    this.textStyle,
    this.hintStyle,
  }) : super(key: key);

  @override
  State<LineNumberTextField> createState() => _LineNumberTextFieldState();
}

class _LineNumberTextFieldState extends State<LineNumberTextField> {
  final ScrollController _lineNumberScrollController = ScrollController();
  final ScrollController _textScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isScrolling = false;

  // 行高常量
  static const double _lineHeight = 20.0;
  static const double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    // 同步滚动
    _textScrollController.addListener(_syncScrollFromText);
    _lineNumberScrollController.addListener(_syncScrollFromLineNumber);
    widget.controller.addListener(_updateLineNumbers);
  }

  @override
  void dispose() {
    _lineNumberScrollController.dispose();
    _textScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncScrollFromText() {
    if (!_isScrolling && _lineNumberScrollController.hasClients) {
      _isScrolling = true;
      _lineNumberScrollController.jumpTo(_textScrollController.offset);
      _isScrolling = false;
    }
  }

  void _syncScrollFromLineNumber() {
    if (!_isScrolling && _textScrollController.hasClients) {
      _isScrolling = true;
      _textScrollController.jumpTo(_lineNumberScrollController.offset);
      _isScrolling = false;
    }
  }

  void _updateLineNumbers() {
    setState(() {});
  }

  List<String> _getLines() {
    final text = widget.controller.text;
    if (text.isEmpty) return ['1'];

    // 按换行符分割
    final lines = text.split('\n');
    List<String> result = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      // 估算每行能显示的字符数（基于容器宽度和字体大小）
      final charsPerLine = 80; // 可以根据实际情况调整

      if (line.length <= charsPerLine) {
        // 单行显示
        result.add('${i + 1}');
      } else {
        // 多行显示，计算需要多少行
        final lineCount = (line.length / charsPerLine).ceil();
        for (int j = 0; j < lineCount; j++) {
          result.add('${i + 1}');
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final lines = _getLines();

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行号区域
          Container(
            width: 50,
            decoration: BoxDecoration(color: Colors.grey.shade50),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false, // 禁用滚动条
              ),
              child: SingleChildScrollView(
                controller: _lineNumberScrollController,
                physics: NeverScrollableScrollPhysics(), // 禁用独立滚动
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        lines.map((lineNumber) {
                          return Container(
                            height: _lineHeight,
                            alignment: Alignment.centerRight,
                            child: Text(
                              lineNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontFamily: 'monospace',
                                height: 1.0, // 固定行高
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
          // 文本输入区域
          Expanded(
            child: SingleChildScrollView(
              controller: _textScrollController,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                readOnly: widget.readOnly,
                maxLines: null,
                style:
                    widget.textStyle ??
                    TextStyle(
                      fontSize: _fontSize,
                      fontFamily: 'monospace',
                      height: _lineHeight / _fontSize, // 精确计算行高比例
                    ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle:
                      widget.hintStyle ??
                      TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: _fontSize,
                        height: _lineHeight / _fontSize,
                      ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
