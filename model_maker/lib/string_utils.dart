import 'package:model_maker/json_tool.dart';

class StringUtils {
  // 下划线转小驼峰
  static String underscoreToCamelCase(String input) {
    if (int.tryParse(input) != null) {
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
}
