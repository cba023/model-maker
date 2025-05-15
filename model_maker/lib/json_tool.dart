import 'dart:convert';
import 'package:model_maker/configurations_model.dart';
import 'package:model_maker/string_utils.dart';
import 'package:model_maker/model_info.dart';

/// JSON工具类
class JsonTool {
  /// 字符串json解析
  static dynamic? jsonStringToDynamic(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      print('JSON 解析错误: $e');
      return null;
    }
  }

  /// 异步获取数据
  static Future<String?> asyncGenerateModels(
    String? jsonStr,
    ConfigurationsModel conf,
  ) async {
    return Future(() => _generateModels(jsonStr, conf));
  }

  /// 转换成模型信息
  static String? _generateModels(String? jsonStr, ConfigurationsModel conf) {
    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }
    var dynamicObj = jsonStringToDynamic(jsonStr);
    ModelInfo? modelInfo = _makeModel(dynamicObj, conf.modelName, '', conf);
    print(modelInfo);
    if (modelInfo != null) {
      String modelStr = '\n' + _modelString(modelInfo, conf);
      if (conf.supportSmartCodable || conf.supportYYModel) {
        if (conf.supportSmartCodable) {
          modelStr = modelStr.replaceRange(0, 0, "import SmartCodable\n");
        }
        if (conf.supportYYModel) {
          modelStr = modelStr.replaceRange(0, 0, "import YYModel\n");
        }
      } else {
        modelStr = modelStr.replaceRange(0, 0, "import Foundation\n");
      }
      print(modelStr);
      return modelStr;
    }
    return null;
  }

  // 生成模型
  static ModelInfo? _makeModel(
    dynamic map,
    String key,
    String superTypeName,
    ConfigurationsModel conf,
  ) {
    String selfTypeName =
        superTypeName + StringUtils.underscoreToPascalCase(key);
    if (selfTypeName.isEmpty) {
      selfTypeName = defaultModelName;
    }
    selfTypeName = selfTypeName.trim();
    ModelInfo modelInfo = ModelInfo(null, map, selfTypeName, [], []);

    List<ModelInfo> modelInfos = [];
    List<PropertyInfo> properties = [];
    if (map is Map) {
      Map m = map;
      _makeSubModelsAndProperties(
        m,
        selfTypeName,
        modelInfos,
        properties,
        conf,
      );
    } else if (map is List) {
      List list = map;
      if (!list.isEmpty) {
        dynamic subObj = list.first;
        if (subObj != null && subObj is Map) {
          _makeSubModelsAndProperties(
            subObj,
            selfTypeName,
            modelInfos,
            properties,
            conf,
          );
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else if (map == null) {
      return null;
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
    ConfigurationsModel conf,
  ) {
    for (var entry in m.entries) {
      String originKey = entry.key;
      dynamic? value = entry.value;
      var key = originKey;
      // conf.isCamelCase
      //     ? StringUtils.underscoreToCamelCase(originKey)
      //     : originKey;
      if (value is! String && value is! double && value is! int) {
        var modelInfo = _makeModel(value, key, selfTypeName, conf);
        if (modelInfo != null) {
          modelInfos.add(modelInfo);
        }
      }

      bool shouldSetToStringDefault =
          (_isInvalidList(value) || (value == null));

      /// 不明类型，默认赋值String类型
      var property = PropertyInfo(
        key,
        shouldSetToStringDefault
            ? "String"
            : _typeName(key, value, selfTypeName),

        /// 空list或null都给成String类型
        value is List,
        true,
        shouldSetToStringDefault,
      );
      properties.add(property);
    }
  }

  /// 判断List是否非法
  static _isInvalidList(dynamic value) {
    if (value is List) {
      List<dynamic> list = value;
      if (list.isEmpty || list.first == null) {
        return true;
      }
    }
    return false;
  }

  static String _typeName(String key, dynamic value, String superTypeName) {
    if (value is String) {
      return "String";
    } else if (value is double) {
      return "Double";
    } else if (value is int) {
      return "Int";
    } else if (value is bool) {
      return "Bool";
    } else {
      if (value is List) {
        List<dynamic> list = value;
        if (list.length > 0) {
          dynamic first = list[0];
          return _typeName(key, first, superTypeName);
        }
      }

      /// 拼接父模型名在前
      return superTypeName + StringUtils.underscoreToPascalCase(key);
    }
  }

  /// 是否是基本数据类型
  static bool _isBasicType(String typeName) {
    return typeName == "String" ||
        typeName == "Int" ||
        typeName == "Double" ||
        typeName == "Bool";
  }

  /// 模型信息转化成模型String
  static String _modelString(ModelInfo modelInfo, ConfigurationsModel conf) {
    var modelStr = "";

    /// 类声明所在的那一行
    String headerLine;
    if (conf.isUsingStruct) {
      headerLine = 'struct ${modelInfo.typeName} {';
      if (conf.supportSmartCodable) {
        headerLine = headerLine.replaceFirst('{', ': SmartCodable {');
      }
    } else {
      headerLine = 'class ${modelInfo.typeName}: NSObject {';
      if (conf.supportSmartCodable) {
        headerLine = headerLine.replaceFirst(' {', ', SmartCodable {');
      }

      /// 检查是否支持public
      if (conf.supportPublic) {
        headerLine = headerLine.replaceRange(0, 0, "public ");
      }
      if (conf.supportYYModel) {
        headerLine = headerLine.replaceFirst(' {', ', YYModel {');
        headerLine = headerLine.replaceRange(
          0,
          0,
          "@objc(${modelInfo.typeName})\n",
        );
      }

      /// 检查是否支持Objc
      if (conf.supportObjc) {
        headerLine = headerLine.replaceRange(0, 0, "@objcMembers\n");
      }
    }
    modelStr += headerLine;

    /// 属性行
    for (var property in modelInfo.properties) {
      String propertyStr;
      String propertyKey =
          conf.isCamelCase
              ? StringUtils.underscoreToCamelCase(property.key)
              : property.key;
      var varDisplay = conf.supportPublic ? '    public var' : '    var';
      if (property.isList) {
        propertyStr = "$varDisplay ${propertyKey}: [${property.type}]?";
      } else {
        var propertyTypeDisplay =
            conf.supportObjc &&
                    (property.type == 'Int' || property.type == 'Double')
                ? '${property.type} = 0'
                : '${property.type}?';

        propertyStr = "$varDisplay ${propertyKey}: $propertyTypeDisplay";
      }
      if (property.isUnidentifiedType) {
        propertyStr += " // TODO: 未识别类型，此处默认设置为String，请手动处理";
      }
      modelStr += "\n$propertyStr";
    }

    /// 是否有需要映射的属性
    var hasNeedMappingKeyProperties =
        modelInfo.properties
            .where(
              (property) =>
                  property.key !=
                  StringUtils.underscoreToCamelCase(property.key),
            )
            .isNotEmpty;

    /// 检查SmartCodable要求的映射关系
    if (conf.supportSmartCodable) {
      if (conf.isCamelCase && hasNeedMappingKeyProperties) {
        var mappingStr =
            "\n\n    ${conf.supportPublic ? 'public ' : ''}static func mappingForKey() -> [SmartKeyTransformer]? {\n        return [";
        for (var property in modelInfo.properties) {
          var camelKey = StringUtils.underscoreToCamelCase(property.key);
          if (camelKey == property.key) {
            continue;
          }
          mappingStr +=
              "\n            CodingKeys.${camelKey} <--- \"${property.key}\",";
        }
        mappingStr += "\n        ]\n    }";

        modelStr += mappingStr;
      }
      if (!conf.isUsingStruct) {
        modelStr +=
            "\n\n    required ${conf.supportPublic ? 'public ' : ''}override init() {\n        super.init()\n    }";
      }
    }

    /// 检查YYModel要求的映射关系
    if (conf.supportYYModel) {
      /// 是否有数组的子模型属性
      var hasListProperty = false;
      for (int i = 0; i < modelInfo.properties.length; i++) {
        var property = modelInfo.properties[i];
        if (property.isList &&
            !property.isUnidentifiedType &&
            !_isBasicType(property.type)) {
          hasListProperty = true;
          break;
        }
      }
      if (hasListProperty) {
        var mappingStr =
            "\n\n    ${conf.supportPublic ? 'public ' : ''}static func modelContainerPropertyGenericClass() -> [String : Any]? {\n        return [";
        for (var property in modelInfo.properties) {
          if (_isBasicType(property.type)) {
            continue;
          }
          String propertyKey =
              conf.isCamelCase
                  ? StringUtils.underscoreToCamelCase(property.key)
                  : property.key;
          mappingStr +=
              "\n            \"$propertyKey\": ${property.type}.self,";
        }
        mappingStr += "\n        ]\n    }";

        modelStr += mappingStr;
      }
      if (conf.isCamelCase && hasNeedMappingKeyProperties) {
        // 如果是驼峰属性，需要开启映射
        var mappingStr =
            "\n\n   ${conf.supportPublic ? 'public ' : ''} static func modelCustomPropertyMapper() -> [String : Any]? {\n        return [";
        for (var property in modelInfo.properties) {
          var camelKey = StringUtils.underscoreToCamelCase(property.key);
          if (camelKey == property.key) {
            continue;
          }
          mappingStr += "\n            \"$camelKey\": \"${property.key}\",";
        }
        mappingStr += "\n        ]\n    }";

        modelStr += mappingStr;
      }
    }

    modelStr += "\n}";
    for (var subModelInfo in modelInfo.subModelInfos) {
      var subModelStr = _modelString(subModelInfo, conf);
      modelStr += "\n\n$subModelStr";
    }
    return modelStr;
  }
}
