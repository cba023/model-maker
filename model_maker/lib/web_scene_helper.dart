import 'dart:convert';

class WebSceneHelper {
  /// 浮点类型的值在web环境解析时x.0的值会被转化成整数，需要标记出来，后期特殊处理，明确成double类型
  static String addTypeMarkersToJsonString(String jsonStr) {
    // 匹配 "key": x.0 模式，并添加 %_key_% 类型标记
    final regex = RegExp(r'"([^"]+)":\s*(\d+)\.0');
    return jsonStr.replaceAllMapped(regex, (match) {
      final key = match.group(1)!;
      final intPart = match.group(2)!;
      return '"$key": $intPart.0, "%--$key--%": "Double"'; // 修改类型标记字段格式
    });
  }

  /// 数组中出现了x.0也要处理（web）
  static String processArrayElements(String jsonStr) {
    // 匹配数值数组，如 "key": [1.0, 2.0, 3]
    final arrayRegex = RegExp(
      r'"([^"]+)":\s*\[\s*((\d+\.0\s*,\s*)*(\d+\.0))\s*\]',
    );

    final res = jsonStr.replaceAllMapped(arrayRegex, (match) {
      final key = match.group(1)!;
      final arrayContent = match.group(2)!;

      // 生成类型标记数组内容
      final typeMarkers = arrayContent
          .split(',')
          .map((element) => element.trim().endsWith('.0') ? 'Double' : 'Int')
          .join(', ');

      return '"$key": [$arrayContent], "%--$key--%": "$typeMarkers"';
    });
    return res;
  }

  static String markDoubleArray(String jsonStr) {
    final regex = RegExp(r'"([^"]+)":\s*\[\s*([^\]]*)\s*\]');
    String result = jsonStr;

    final matches = regex.allMatches(jsonStr);
    int offset = 0;

    for (final match in matches) {
      final key = match.group(1)!;
      final arrayContent = match.group(2)?.trim() ?? '';

      if (arrayContent.isEmpty) continue;

      final elements = arrayContent.split(',');
      if (elements.isEmpty) continue;

      final firstElement = elements.first.trim();
      String? typeMark;

      // 检查是否为字符串
      if ((firstElement.startsWith('"') && firstElement.endsWith('"')) ||
          (firstElement.startsWith("'") && firstElement.endsWith("'"))) {
        typeMark = 'String';
      }
      // 检查是否为数字
      else {
        final numValue = double.tryParse(firstElement);
        if (numValue != null) {
          // 严格检查字符串格式是否包含小数点
          typeMark = firstElement.contains('.') ? 'Double' : 'Int';
        } else {
          continue;
        }
      }

      final originalMatch = match.group(0)!;
      final replacement = '"$key":[$arrayContent], "%--$key--%":"$typeMark"';

      result = result.replaceRange(
        match.start + offset,
        match.end + offset,
        replacement,
      );

      offset += replacement.length - originalMatch.length;
    }

    return result;
  }
}
