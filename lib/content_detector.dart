import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:model_maker/document_tool.dart';

// 缓存类，用于避免重复计算
class _ContentCache {
  static final Map<String, ContentType> _cache = {};
  static const int _maxCacheSize = 100;

  static ContentType? get(String text) {
    return _cache[text];
  }

  static void set(String text, ContentType type) {
    if (_cache.length >= _maxCacheSize) {
      // 简单的LRU策略：清除一半缓存
      final keys = _cache.keys.toList();
      for (int i = 0; i < keys.length ~/ 2; i++) {
        _cache.remove(keys[i]);
      }
    }
    _cache[text] = type;
  }

  static void clear() {
    _cache.clear();
  }

  /// 获取缓存大小
  static int get cacheSize => _cache.length;
}

enum ContentType {
  empty, // 没有输入信息
  invalidJson, // JSON非法
  validJson, // JSON数据
  validDocument, // A类接口文档类型
}

class ContentDetector {
  /// 检测输入内容的类型（带缓存优化）
  static ContentType detectContentType(String text) {
    final trimmedText = text.trim();

    // 检查缓存
    final cachedType = _ContentCache.get(trimmedText);
    if (cachedType != null) {
      return cachedType;
    }

    // 检查是否为空
    if (trimmedText.isEmpty) {
      _ContentCache.set(trimmedText, ContentType.empty);
      return ContentType.empty;
    }

    // 对于大文本，先进行快速检查
    if (trimmedText.length > 10000) {
      // 大文本优化：只检查前1000个字符来判断类型
      final preview = trimmedText.substring(0, 1000);
      final type = _detectContentTypeInternal(preview);
      _ContentCache.set(trimmedText, type);
      return type;
    }

    final type = _detectContentTypeInternal(trimmedText);
    _ContentCache.set(trimmedText, type);
    return type;
  }

  /// 内部检测方法
  static ContentType _detectContentTypeInternal(String text) {
    // 优先检查是否为A类接口文档类型
    if (_isValidDocument(text)) {
      return ContentType.validDocument;
    }

    // 检查是否为有效的JSON
    try {
      jsonDecode(text);
      return ContentType.validJson;
    } catch (e) {
      // JSON解析失败，检查是否包含JSON格式的字符
      if (_looksLikeJson(text)) {
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
