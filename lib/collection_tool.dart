class Collectiontool {
  static bool areSetsEqual(Set<dynamic> set1, Set<dynamic> set2) {
    if (identical(set1, set2)) return true;
    return set1.length == set2.length && set1.containsAll(set2);
  }

  static bool isMapList(List list) {
    return list.every((element) => element is Map);
  }

  /// 多维的Map List
  static bool isMultiDimensionalList(List list) {
    return list.isNotEmpty && list[0] is List;
  }

  /// 判断任意维数的数组最内层是int,string,bool或double等基本数据类型
  static bool isDeepestPrimitive(List list) {
    bool checkElement(dynamic element) {
      if (element is List) {
        // 递归检查子列表
        if (element.isEmpty) return true; // 空列表视为合法
        return element.every(checkElement);
      } else {
        // 检查是否为目标类型
        return element is bool ||
            element is int ||
            element is double ||
            element is String;
      }
    }

    return list.isNotEmpty && list.every(checkElement);
  }
}
