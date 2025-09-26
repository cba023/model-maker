import 'dart:convert';

class JsonFormatter {
  // 缓存已解析的JSON对象，避免重复解析
  static final Map<String, dynamic> _jsonCache = {};
  static const int _maxCacheSize = 50;

  /// 检查文本是否为有效的JSON（带缓存优化）
  static bool isValidJson(String text) {
    if (text.trim().isEmpty) return false;

    final trimmedText = text.trim();

    // 检查缓存
    if (_jsonCache.containsKey(trimmedText)) {
      return true;
    }

    try {
      final jsonData = jsonDecode(trimmedText);
      _cacheJson(trimmedText, jsonData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 格式化JSON文本（带缓存优化）
  static String formatJson(String text) {
    if (text.trim().isEmpty) return text;

    final trimmedText = text.trim();

    try {
      // 尝试从缓存获取
      dynamic jsonData = _jsonCache[trimmedText];
      if (jsonData == null) {
        jsonData = jsonDecode(trimmedText);
        _cacheJson(trimmedText, jsonData);
      }

      const encoder = JsonEncoder.withIndent('  '); // 使用2个空格缩进
      return encoder.convert(jsonData);
    } catch (e) {
      return text; // 如果格式化失败，返回原文本
    }
  }

  /// 压缩JSON文本（移除所有空格和换行）
  static String minifyJson(String text) {
    if (text.trim().isEmpty) return text;

    final trimmedText = text.trim();

    try {
      // 尝试从缓存获取
      dynamic jsonData = _jsonCache[trimmedText];
      if (jsonData == null) {
        jsonData = jsonDecode(trimmedText);
        _cacheJson(trimmedText, jsonData);
      }

      const encoder = JsonEncoder();
      return encoder.convert(jsonData);
    } catch (e) {
      return text; // 如果压缩失败，返回原文本
    }
  }

  /// 缓存JSON数据
  static void _cacheJson(String text, dynamic jsonData) {
    if (_jsonCache.length >= _maxCacheSize) {
      // 简单的LRU策略：清除一半缓存
      final keys = _jsonCache.keys.toList();
      for (int i = 0; i < keys.length ~/ 2; i++) {
        _jsonCache.remove(keys[i]);
      }
    }
    _jsonCache[text] = jsonData;
  }

  /// 清除缓存
  static void clearCache() {
    _jsonCache.clear();
  }
}
