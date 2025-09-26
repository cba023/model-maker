import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:model_maker/document_tool.dart';

enum ContentType {
  empty, // 没有输入信息
  invalidJson, // JSON非法
  validJson, // JSON数据
  validDocument, // A类接口文档类型
}

class ContentDetector {
  /// 检测输入内容的类型
  static ContentType detectContentType(String text) {
    final trimmedText = text.trim();

    // 检查是否为空
    if (trimmedText.isEmpty) {
      return ContentType.empty;
    }

    // 优先检查是否为A类接口文档类型
    if (_isValidDocument(trimmedText)) {
      return ContentType.validDocument;
    }

    // 检查是否为有效的JSON
    try {
      jsonDecode(trimmedText);
      return ContentType.validJson;
    } catch (e) {
      // JSON解析失败，检查是否包含JSON格式的字符
      if (_looksLikeJson(trimmedText)) {
        return ContentType.invalidJson;
      }
    }

    // 默认返回无效JSON
    return ContentType.invalidJson;
  }

  /// 检查文本是否看起来像JSON
  static bool _looksLikeJson(String text) {
    // 检查是否包含JSON的特征字符
    return text.contains('{') || text.contains('[') || text.contains('"');
  }

  /// 检查是否为有效的A类接口文档
  static bool _isValidDocument(String text) {
    // 使用与parseDocument相同的逻辑：检查是否能提取到标题
    final title = DocumentTool.extractTitle(text);
    return title != null && title.isNotEmpty;
  }

  /// 获取内容类型的显示文本
  static String getDisplayText(ContentType type) {
    switch (type) {
      case ContentType.empty:
        return '没有输入信息';
      case ContentType.invalidJson:
        return 'JSON非法';
      case ContentType.validJson:
        return 'JSON数据';
      case ContentType.validDocument:
        return 'A类接口文档';
    }
  }

  /// 获取内容类型对应的颜色
  static Color getDisplayColor(ContentType type) {
    switch (type) {
      case ContentType.empty:
        return Colors.grey;
      case ContentType.invalidJson:
        return Colors.red;
      case ContentType.validJson:
        return Colors.green;
      case ContentType.validDocument:
        return Colors.blue;
    }
  }
}
