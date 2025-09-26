import 'dart:convert';

class JsonFormatter {
  /// 检查文本是否为有效的JSON
  static bool isValidJson(String text) {
    if (text.trim().isEmpty) return false;

    try {
      jsonDecode(text.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 格式化JSON文本
  static String formatJson(String text) {
    if (text.trim().isEmpty) return text;

    try {
      final dynamic jsonData = jsonDecode(text.trim());
      const encoder = JsonEncoder.withIndent('  '); // 使用2个空格缩进
      return encoder.convert(jsonData);
    } catch (e) {
      return text; // 如果格式化失败，返回原文本
    }
  }

  /// 压缩JSON文本（移除所有空格和换行）
  static String minifyJson(String text) {
    if (text.trim().isEmpty) return text;

    try {
      final dynamic jsonData = jsonDecode(text.trim());
      const encoder = JsonEncoder();
      return encoder.convert(jsonData);
    } catch (e) {
      return text; // 如果压缩失败，返回原文本
    }
  }
}
