import 'dart:async';
import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:model_maker/content_detector.dart';

class CodeTextFieldWrapper extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final Function(String)? onChanged;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool showFormatButton; // 是否显示格式化按钮
  final VoidCallback? onFormat; // 格式化回调
  final bool showFloatingButtons; // 是否显示悬浮按钮（内容检测和格式化）
  final VoidCallback? onLoadSample; // 加载示例文档回调
  final VoidCallback? onClear; // 清空内容回调
  final bool showCopyButton; // 是否显示复制按钮
  final VoidCallback? onCopy; // 复制回调

  const CodeTextFieldWrapper({
    Key? key,
    required this.controller,
    this.hintText = '',
    this.readOnly = false,
    this.onChanged,
    this.textStyle,
    this.hintStyle,
    this.showFormatButton = false,
    this.onFormat,
    this.showFloatingButtons = true, // 默认显示悬浮按钮
    this.onLoadSample,
    this.onClear,
    this.showCopyButton = false, // 默认不显示复制按钮
    this.onCopy,
  }) : super(key: key);

  @override
  State<CodeTextFieldWrapper> createState() => _CodeTextFieldWrapperState();
}

class _CodeTextFieldWrapperState extends State<CodeTextFieldWrapper> {
  late CodeController _codeController;
  late FocusNode _focusNode;
  ContentType _contentType = ContentType.empty;
  Timer? _debounceTimer;

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
      _updateContentType();
    });

    // 监听外部控制器变化
    widget.controller.addListener(() {
      if (widget.controller.text != _codeController.text) {
        _codeController.text = widget.controller.text;
        // 立即更新UI状态
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 更新内容类型（带防抖优化）
  void _updateContentType() {
    // 取消之前的定时器
    _debounceTimer?.cancel();

    // 设置新的防抖定时器
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      if (mounted) {
        final newType = ContentDetector.detectContentType(_codeController.text);
        if (_contentType != newType) {
          setState(() {
            _contentType = newType;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                  fontSize: 16,
                  fontFamily: 'monospace',
                  color: Colors.black87, // 更深的正文颜色
                ),
            background: Colors.white,
            cursorColor: Colors.blue,
            horizontalScroll: true,
            wrap: false, // 关闭软换行
            expands: true,
          ),
        ),
        // 提示文字（当输入框为空时显示）
        if (_codeController.text.isEmpty)
          Positioned(
            top: 6.5, // 再向上移动一点，与第一行文本对齐
            left: 58, // 行号区域宽度 + 边距
            child: Text(
              widget.hintText,
              style:
                  widget.hintStyle ??
                  TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontFamily: 'monospace',
                    height: 1.0, // 确保行高一致
                  ),
            ),
          ),
        // 内容检测信息和格式化按钮（只在需要时显示）
        if (widget.showFloatingButtons)
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 清空按钮（只在有内容时显示）
                if (_contentType != ContentType.empty && widget.onClear != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onClear,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.clear, color: Colors.red, size: 16),
                              SizedBox(width: 1),
                              Text(
                                '清空内容',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // 示例文档按钮（只在没有输入信息时显示）
                if (_contentType == ContentType.empty &&
                    widget.onLoadSample != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onLoadSample,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description,
                                color: Colors.orange,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '试试解析示例文档',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                // 内容检测信息
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: ContentDetector.getDisplayColor(_contentType),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        ContentDetector.getDisplayText(_contentType),
                        style: TextStyle(
                          color: ContentDetector.getDisplayColor(_contentType),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                // 格式化按钮（只在有效JSON时显示）
                if (widget.showFormatButton && widget.onFormat != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onFormat,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.format_align_left,
                                color: Colors.blue,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '格式化JSON',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // 复制按钮（独立显示，不受showFloatingButtons限制）
        if (widget.showCopyButton &&
            widget.onCopy != null &&
            widget.controller.text.isNotEmpty)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, color: Colors.green, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '复制代码',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
