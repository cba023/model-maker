import 'dart:io';

class MarkdownTable {
  final MarkdownRow headers;
  final List<MarkdownRow> rows;

  MarkdownTable(this.headers, this.rows);

  @override
  String toString() => 'Headers: $headers\nRows: $rows';
}

class MarkdownRow {
  final String property;
  final String desc;
  final String type;
  final String scheme;

  MarkdownRow(this.property, this.desc, this.type, this.scheme);
}

/// Markdown文档处理工具类
class DocumentTool {
  static List<MarkdownTable> extractMarkdownTables(String content) {
    const columnCount = 4; // 固定4列
    final tables = <MarkdownTable>[];

    // 正则表达式（严格匹配4列）
    final rowPattern = RegExp(
      r'^\s*\|?\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|?\s*$',
      multiLine: true,
    );

    // 分割文档为潜在表格块
    final blocks = content.split(RegExp(r'\n{2,}')); // 以空行分割区块

    for (final block in blocks) {
      final lines =
          block
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
      if (lines.length < 3) continue; // 至少需要标题行、分隔行、数据行

      try {
        // 验证表格结构
        final headers = _parseRow(lines[0], rowPattern, columnCount);
        final separatorValid = lines[1].contains(
          RegExp(r'^\|?(\s*:?-{3,}:?\s*\|){4}$'),
        );
        final dataRows =
            lines
                .sublist(2)
                .map((line) => _parseRow(line, rowPattern, columnCount))
                .toList();

        if (separatorValid) {
          tables.add(MarkdownTable(headers, dataRows));
        }
      } catch (_) {
        // 忽略格式不匹配的区块
      }
    }

    return tables;
  }

  static MarkdownRow _parseRow(
    String line,
    RegExp pattern,
    int expectedColumns,
  ) {
    final match = pattern.firstMatch(line);
    if (match == null || match.groupCount != expectedColumns) {
      throw FormatException('Invalid row format: $line');
    }

    return MarkdownRow(
      match.group(1)?.trim() ?? "",
      match.group(2)?.trim() ?? "",
      match.group(3)?.trim() ?? "",
      match.group(4)?.trim() ?? "",
    );
  }

  /// 从markdown中提取json文件
  static String? extracJsonResponse(String docuement) {
    final pattern = RegExp(r'```json\s*?\n([\s\S]*?)\n\s*```', multiLine: true);
    var last =
        pattern
            .allMatches(docuement)
            .map((match) => match.group(1)!.trim()) // 提取核心JSON内容
            .toList()
            .last;
    return last;
  }

  /// 解析API地址
  static String? extractApiPath(String document) {
    final regex = RegExp(r'`(/peanut/)(.+?)`');
    final match = regex.firstMatch(document);
    if (match != null) {
      return match.group(2);
    }
    return null;
  }

  /// 从 Markdown 格式文本中提取二级标题内容（## 开头到换行前的文本）
  static String? extractTitle(String document) {
    final regex = RegExp(r'^##\s*(.*?)$', multiLine: true);
    final match = regex.firstMatch(document);
    return match?.group(1);
  }
}
