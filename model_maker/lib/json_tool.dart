import 'dart:convert';
import 'dart:ffi';

import 'package:model_maker/StringUtils';
import 'package:model_maker/model_info.dart';

/// JSON工具类
class JsonTool {
  /// 字符串转map
  static Map<String, dynamic> jsonStringToMap(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('JSON 解析错误: $e');
      return {};
    }
  }

  /// 转换成模型信息
  static String? generateModels(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }
    var map = jsonStringToMap(jsonStr);
    ModelInfo? modelInfo = _makeModel(map, 'UserInfo', 'TT');
    print(modelInfo);
    if (modelInfo != null) {
      String modelStr = _modelString(modelInfo);
      print(modelStr);
      return modelStr;
    }
    return null;
  }

  // 生成模型
  static ModelInfo? _makeModel(dynamic map, String key, String superTypeName) {
    String selfTypeName =
        superTypeName + StringUtils.underscoreToPascalCase(key);

    ModelInfo modelInfo = ModelInfo(null, map, selfTypeName, [], []);

    List<ModelInfo> modelInfos = [];
    List<PropertyInfo> properties = [];
    if (map is Map) {
      Map m = map;
      _makeSubModelsAndProperties(m, selfTypeName, modelInfos, properties);
    } else if (map is List) {
      List list = map;
      dynamic subObj = list.first;
      if (subObj != null && subObj is Map) {
        _makeSubModelsAndProperties(
          subObj,
          selfTypeName,
          modelInfos,
          properties,
        );
      } else {
        print(subObj);
        var property = PropertyInfo(
          key,
          _typeName(key, subObj, selfTypeName),
          subObj is List,
        );
        properties.add(property);
      }
    }
    modelInfo.subModelInfos = modelInfos;
    modelInfo.properties = properties;
    return modelInfo;
  }

  // 生成子模型和属性
  static void _makeSubModelsAndProperties(
    Map<dynamic, dynamic> m,
    String selfTypeName,
    List<ModelInfo> modelInfos,
    List<PropertyInfo> properties,
  ) {
    for (var entry in m.entries) {
      String originKey = entry.key;
      dynamic value = entry.value;

      if (value is! String && value is! double && value is! int) {
        var modelInfo = _makeModel(value, originKey, selfTypeName);
        if (modelInfo != null) {
          modelInfos.add(modelInfo);
        }
      }
      var property = PropertyInfo(
        originKey,
        _typeName(originKey, value, selfTypeName),
        value is List,
      );
      properties.add(property);
    }
  }

  static String _typeName(String key, dynamic value, String superTypeName) {
    if (value is String) {
      return "String";
    } else if (value is double) {
      return "Double";
    } else if (value is int) {
      return "Int";
    } else {
      /// 拼接父模型名在前
      return superTypeName + StringUtils.underscoreToPascalCase(key);
    }
  }

  static String _modelString(ModelInfo modelInfo) {
    var modelStr = "";
    var headerLine = "class ${modelInfo.typeName}: NSObject {";
    modelStr += headerLine;
    for (var property in modelInfo.properties) {
      String propertyStr;
      if (property.isList) {
        propertyStr = "    var ${property.key}: [${property.type}]?";
      } else {
        propertyStr = "    var ${property.key}: ${property.type}?";
      }
      modelStr += "\n$propertyStr";
    }
    modelStr += "\n}";
    for (var subModelInfo in modelInfo.subModelInfos) {
      var subModelStr = _modelString(subModelInfo);
      modelStr += "\n\n$subModelStr";
    }
    return modelStr;
  }
}
