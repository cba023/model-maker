import 'package:model_maker/json_tool.dart';

class StringUtils {
  // 下划线转小驼峰
  static String underscoreToCamelCase(String input) {
    if (RegExp(r'^\d').hasMatch(input)) {
      return "_$input";
    }
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
    if (int.tryParse(input) != null) {
      return "_$input";
    }
    final parts = input.split('_');
    return parts.map((part) {
      return part.isNotEmpty
          ? '${part[0].toUpperCase()}${part.substring(1)}'
          : '';
    }).join();
  }

  // `TODO`项查找
  static int countofTodo(String text) {
    int count = 0;
    int startIndex = 0;
    while (true) {
      int index = text.indexOf(todoKey, startIndex);
      if (index == -1) break;
      count++;
      startIndex = index + todoKey.length;
    }
    return count;
  }

  /// 把json串value中.0替换成.1
  static String replaceZerosInJson(String jsonStr) {
    final result = StringBuffer();
    final buffer = StringBuffer();
    bool inString = false;
    bool escape = false;
    bool inNumber = false;

    void flushBuffer() {
      if (buffer.isEmpty) return;

      final numStr = buffer.toString();
      buffer.clear();

      // 匹配整数部分 + .0 + 可选指数部分
      final regex = RegExp(r'^(-?\d+)\.0((?:[eE][-+]?\d+)?)$');
      final match = regex.firstMatch(numStr);

      if (match != null) {
        result.write('${match[1]}.1${match[2] ?? ''}');
      } else {
        result.write(numStr);
      }
    }

    for (int i = 0; i < jsonStr.length; i++) {
      final c = jsonStr[i];

      if (inString) {
        result.write(c);
        if (escape) {
          escape = false;
        } else if (c == '\\') {
          escape = true;
        } else if (c == '"') {
          inString = false;
        }
      } else {
        if (c == '"') {
          flushBuffer();
          inString = true;
          result.write(c);
        } else if (c == '-' ||
            (c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57)) {
          // 数字开始：负号或数字
          if (!inNumber) {
            flushBuffer();
            inNumber = true;
          }
          buffer.write(c);
        } else if (inNumber && (c == '.' || c == 'e' || c == 'E' || c == '+')) {
          // 数字中间的特殊字符
          buffer.write(c);
        } else {
          // 数字结束
          if (inNumber) {
            flushBuffer();
            inNumber = false;
          }
          result.write(c);
        }
      }
    }

    flushBuffer(); // 处理末尾可能剩余的数字
    return result.toString();
  }

  /// 检查外层是否有成对方括号
  static bool isValidBracketString(String s) {
    if (!s.startsWith("[")) {
      return false;
    }
    int count = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '[') {
        count++;
      } else if (s[i] == ']') {
        if (count == 0) return false;
        count--;
      }
    }
    return count == 0;
  }
}
