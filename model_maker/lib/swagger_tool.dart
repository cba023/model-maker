class SwaggerTable {
  final List<SwaggerRow> rows;
  SwaggerTable(this.rows);
}

class SwaggerRow {
  final String property;
  final String type;
  final String desc;
  SwaggerRow(this.property, this.type, this.desc);
}

/// Swagger文档解析类（Mate项目）
class SwaggerTool {
  /// 查找json中
  static List<SwaggerTable> extractBracesContent(String? input) {
    if (input == null) {
      return [];
    }
    // 创建匹配花括号内容的正则表达式，排除嵌套情况
    RegExp regExp = RegExp(r'\S+\s*\{([^}]*)\}');
    // 获取所有匹配项
    Iterable<Match> matches = regExp.allMatches(input);
    // 提取每个匹配的捕获组内容
    List<String> sections =
        matches
            .map((match) => match.group(1) ?? '') // 获取第一个捕获组，非空处理
            .toList();
    List<SwaggerTable> tables = [];
    for (var element in sections) {
      List<SwaggerRow> rowInfos = [];
      var propertyStrs = element.split(",\n");
      for (var rowStr in propertyStrs) {
        var rowStrFormatted = rowStr.trim();
        var rowInfo = _extractRowContent(rowStrFormatted);
        if (rowInfo != null) {
          rowInfos.add(rowInfo);
        }
      }
      SwaggerTable table = SwaggerTable(rowInfos);
      tables.add(table);
    }
    return tables;
  }

  /// 获取单行的属性名
  static String? _extractRowProperty(String input) {
    // 正则表达式：匹配第一个 `(` 之前的内容（不包含空格）
    RegExp regExp = RegExp(r'^([^(]*)');
    Match? match = regExp.firstMatch(input);

    if (match != null) {
      String result = match.group(1)?.trim() ?? ""; // 去除首尾空格
      return result;
    }
    return null;
  }

  /// 获取单行的属性的描述信息
  static String? _extractRowDesc(String input) {
    RegExp regExp = RegExp(r':\s+(.*)');
    Match? match = regExp.firstMatch(input);

    if (match != null) {
      String result = match.group(1)?.trim() ?? "";
      return result;
    }
    return null;
  }

  /// 获取单行的属性的数据类型信息
  static String? _extractRowType(String input) {
    RegExp regExp = RegExp(r'\(([^),]*)');
    Match? match = regExp.firstMatch(input);

    if (match != null) {
      String result = match.group(1)?.trim() ?? "";
      return result;
    }
    return null;
  }

  /// 单行数据模型化
  static SwaggerRow? _extractRowContent(String? input) {
    if (input == null) {
      return null;
    }
    String? property = _extractRowProperty(input);
    String? type = _extractRowType(input);
    String? desc = _extractRowDesc(input);
    SwaggerRow row = SwaggerRow(property ?? "", type ?? "", desc ?? "");
    return row;
  }
}
