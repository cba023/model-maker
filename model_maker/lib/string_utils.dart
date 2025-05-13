class StringUtils {
  // 下划线转小驼峰
  static String underscoreToCamelCase(String input) {
    final parts = input.split('_');
    if (parts.isEmpty) {
      return '';
    }
    final firstPart = parts[0];
    final restParts =
        parts.sublist(1).map((part) {
          return part.isNotEmpty
              ? '${part[0].toUpperCase()}${part.substring(1)}'
              : '';
        }).join();
    return '$firstPart$restParts';
  }

  // 下划线转大驼峰
  static String underscoreToPascalCase(String input) {
    final parts = input.split('_');
    return parts.map((part) {
      return part.isNotEmpty
          ? '${part[0].toUpperCase()}${part.substring(1)}'
          : '';
    }).join();
  }

  /// 小驼峰转下划线
  static String camelToSnake(String text) {
    // 处理以大写字母开头的情况（如："Name" → "name"）
    if (text.isEmpty) return '';
    String result = text[0].toLowerCase();

    // 遍历剩余字符，在大写字母前添加下划线
    for (int i = 1; i < text.length; i++) {
      if (text[i].toUpperCase() == text[i] && text[i - 1] != '_') {
        result += '_${text[i].toLowerCase()}';
      } else {
        result += text[i];
      }
    }

    return result;
  }
}
