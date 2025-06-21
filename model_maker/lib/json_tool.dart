import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:model_maker/collection_tool.dart';
import 'package:model_maker/configurations_model.dart';
import 'package:model_maker/document_tool.dart';
import 'package:model_maker/string_utils.dart';
import 'package:model_maker/model_info.dart';
import 'package:collection/collection.dart';
import 'package:model_maker/swagger_tool.dart';

final todoKey = '// TODO: ';

/// JSON工具类
class JsonTool {
  /// 字符串json解析
  static dynamic _jsonStringToDynamic(
    String jsonString,
    ConfigurationsModel conf,
  ) {
    try {
      var formatedJsonStr =
          !kIsWeb ? jsonString : StringUtils.replaceZerosInJson(jsonString);
      return json.decode(formatedJsonStr);
    } catch (e) {
      return null;
    }
  }

  /// 解析文档
  static String? parseDocument(
    String documentString,
    ConfigurationsModel conf,
  ) {
    // 优化表格格式
    var formattedDoc = documentString.replaceAll('            |', '|');
    var tables = DocumentTool.extractMarkdownTables(formattedDoc);
    var json = DocumentTool.extracJsonResponse(formattedDoc);
    var apiPath = DocumentTool.extractApiPath(formattedDoc);
    var title = DocumentTool.extractTitle(formattedDoc);
    String? result = _generateModels(json, tables, title, apiPath, [], conf);
    return result;
  }

  /// 异步获取数据
  static Future<String?> asyncGenerateModels(
    String? jsonStr,
    String? mateModelInfoString,
    ConfigurationsModel conf,
  ) async {
    return Future(() {
      var title = DocumentTool.extractTitle(jsonStr ?? "");
      if (title != null) {
        var res = parseDocument(jsonStr ?? "", conf);
        return res;
      }
      List<SwaggerTable> swaggerTables =
          conf.isMate
              ? SwaggerTool.extractBracesContent(mateModelInfoString)
              : [];

      var jsonRes = _generateModels(
        jsonStr,
        [],
        null,
        null,
        swaggerTables,
        conf,
      );
      return jsonRes;
    });
  }

  /// 转换成模型信息
  static String? _generateModels(
    String? jsonStr,
    List<MarkdownTable> markdownTables,
    String? documentTitle,
    String? apiPath,
    List<SwaggerTable> swaggerTables,
    ConfigurationsModel conf,
  ) {
    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }
    var dynamicObj = _jsonStringToDynamic(jsonStr, conf);
    ModelInfo? modelInfo = _makeModel(
      dynamicObj,
      conf.modelName,
      '',
      markdownTables,
      documentTitle ?? "",
      swaggerTables,
      null,
      conf,
    );
    print(modelInfo);
    if (modelInfo != null) {
      String modelStr = '\n${_modelString(modelInfo, conf)}';
      if (conf.supportSmartCodable || conf.supportYYModel) {
        if (conf.supportSmartCodable) {
          modelStr = modelStr.replaceRange(0, 0, "import SmartCodable\n");
        }
        if (conf.supportYYModel) {
          modelStr = modelStr.replaceRange(0, 0, "import YYModel\n");
        }
      }
      if (!conf.supportSmartCodable && !conf.supportYYModel) {
        modelStr = modelStr.replaceRange(0, 0, "import Foundation\n");
      }
      if (apiPath != null && apiPath.isNotEmpty) {
        modelStr = modelStr.replaceRange(0, 0, "// API: $apiPath\n");
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
    List<MarkdownTable> markdownTables,
    String desc,
    List<SwaggerTable> swaggerTables,
    String? sameModelTypeName,
    ConfigurationsModel conf,
  ) {
    String selfTypeName =
        superTypeName + StringUtils.underscoreToPascalCase(key);
    if (selfTypeName.isEmpty) {
      selfTypeName = defaultModelName;
    }
    selfTypeName = selfTypeName.trim();
    ModelInfo modelInfo = ModelInfo(
      null,
      map,
      selfTypeName,
      [],
      [],
      desc,
      sameModelTypeName,
    );

    List<ModelInfo> modelInfos = [];
    List<PropertyInfo> properties = [];
    if (map is Map) {
      Map m = map;
      _makeSubModelsAndProperties(
        m,
        selfTypeName,
        modelInfos,
        properties,
        markdownTables,
        swaggerTables,
        conf,
      );
    } else if (map is List) {
      List list = map;
      if (list.isEmpty ||
          (!Collectiontool.isMapList(list) &&
              !Collectiontool.isMultiDimensionalList(list))) {
        return null;
      }
      Map effectSubObj = {};
      for (var i = 0; i < list.length; i++) {
        var elem = list[i];
        if (elem is Map) {
          effectSubObj.addAll(elem);
        } else if (elem is List) {
          Map? map = fetchListInnerMap(elem);
          if (map != null) {
            effectSubObj.addAll(map);
          }
        }
      }
      _makeSubModelsAndProperties(
        effectSubObj,
        selfTypeName,
        modelInfos,
        properties,
        markdownTables,
        swaggerTables,
        conf,
      );
    } else if (map == null) {
      return null;
    }
    modelInfo.subModelInfos = modelInfos;
    modelInfo.properties = properties;
    return modelInfo;
  }

  /// 获取列表中最内层的Map,没有则返回空
  static Map? fetchListInnerMap(List list) {
    var first = list.firstOrNull;
    if (first is Map) {
      return first;
    } else if (first is List) {
      return fetchListInnerMap(first);
    }
    return null;
  }

  // 生成子模型和属性
  static void _makeSubModelsAndProperties(
    Map<dynamic, dynamic> m,
    String selfTypeName,
    List<ModelInfo> modelInfos,
    List<PropertyInfo> properties,
    List<MarkdownTable> markdownTables,
    List<SwaggerTable> swaggerTables,
    ConfigurationsModel conf,
  ) {
    MarkdownTable? table = markdownTables.firstWhereOrNull((table) {
      var tableProperties =
          table.rows.map((row) {
            return row.property;
          }).toSet();
      var keys = m.keys.toSet();
      return Collectiontool.areSetsEqual(tableProperties, keys);
    });

    SwaggerTable? swaggerTable;
    if (conf.isMate) {
      /// 解析Mate的Swagger文档
      swaggerTable = swaggerTables.firstWhereOrNull((table) {
        var tableProperties =
            table.rows.map((row) {
              return row.property;
            }).toSet();
        var keys = m.keys.toSet();
        return Collectiontool.areSetsEqual(tableProperties, keys);
      });
    }

    for (var entry in m.entries) {
      String originKey = entry.key;
      dynamic value = entry.value;
      var key = originKey;
      MarkdownRow? row;
      SwaggerRow? swaggerRow;
      if (table != null && table.rows.isNotEmpty) {
        row = table.rows.firstWhereOrNull((row) {
          return row.property == key;
        });
      }
      if (table == null &&
          conf.isMate &&
          swaggerTable != null &&
          swaggerTable.rows.isNotEmpty) {
        swaggerRow = swaggerTable.rows.firstWhereOrNull((row) {
          return row.property == key;
        });
      }

      if (value is! String &&
          value is! double &&
          value is! int &&
          value is! bool) {
        var modelInfo = _makeModel(
          value,
          key,
          selfTypeName,
          markdownTables,
          row?.desc ?? swaggerRow?.desc ?? "",
          swaggerTables,
          null,
          conf,
        );

        /// 模型去重
        if (modelInfo != null) {
          var sameModel = modelInfos.firstWhereOrNull((elementModel) {
            var etypes = elementModel.properties.map((p) => p.type).toSet();
            var ekeys = elementModel.properties.map((p) => p.key).toSet();
            var eIsList = elementModel.properties.map((p) => p.isList).toSet();
            var types = modelInfo.properties.map((p) => p.type).toSet();
            var keys = modelInfo.properties.map((p) => p.key).toSet();
            var isList = elementModel.properties.map((p) => p.isList).toSet();
            var res =
                Collectiontool.areSetsEqual(etypes, types) &&
                Collectiontool.areSetsEqual(ekeys, keys) &&
                Collectiontool.areSetsEqual(eIsList, isList);
            return res;
          });
          if (sameModel != null) {
            modelInfo.sameModelTypeName = sameModel.typeName;
          }
        }

        if (modelInfo != null &&
            modelInfo.value is List &&
            !Collectiontool.isDeepestPrimitive(modelInfo.value)) {
          modelInfos.add(modelInfo);
        }
      }

      final isInvalidResult = _isInvalidList(value, 0);
      bool shouldSetToStringDefault = isInvalidResult.$1 || value == null;
      final depth = isInvalidResult.$2;
      var type = _typeName(key, value, selfTypeName, m);
      if (shouldSetToStringDefault) {
        type = "String";
        for (int i = 0; i < depth; i++) {
          type = "[$type]";
        }
      } else {
        var model = modelInfos.firstWhereOrNull((model) {
          return model.typeName == type && model.sameModelTypeName != null;
        });
        var sameModelName = model?.sameModelTypeName;
        if (sameModelName != null) {
          type = sameModelName;
        }
      }

      var property = PropertyInfo(
        key,
        type,
        value is List,
        true,
        row?.desc ?? swaggerRow?.desc ?? "",
        row?.type ?? swaggerRow?.type ?? "",
        shouldSetToStringDefault,
      );
      if (property.key.isNotEmpty) {
        properties.add(property);
      }
    }
  }

  /// 判断List是否非法
  static (bool, int) _isInvalidList(dynamic value, int depth) {
    if (value is List) {
      List<dynamic> list = value;
      if (list.isEmpty || list.first == null) {
        return (true, depth);
      }
      if (list.first is List) {
        depth += 1;
        return _isInvalidList(list.first, depth);
      }
    }
    return (false, depth);
  }

  /// 根据配置信息确定是否显示public前缀
  static String _publicPan(ConfigurationsModel conf) {
    return conf.supportPublic ? 'public ' : '';
  }

  static String _typeName(
    String key,
    dynamic value,
    String superTypeName,
    Map m,
  ) {
    if (value is String) {
      return "String";
    } else if (value is int) {
      return "Int";
    } else if (value is double) {
      return "Double";
    } else if (value is bool) {
      return "Bool";
    } else {
      if (value is List) {
        List<dynamic> list = value;
        if (list.isNotEmpty) {
          dynamic first = list.first;
          if (first is List) {
            return "[${_typeName(key, first, superTypeName, m)}]";
          } else {
            return _typeName(key, first, superTypeName, m);
          }
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

  static bool _isObjcShouldDefaultValueType(String typeName) {
    return typeName == "Int" || typeName == "Double" || typeName == "Bool";
  }

  /// 模型信息转化成模型String
  static String _modelString(ModelInfo modelInfo, ConfigurationsModel conf) {
    var modelStr = "";

    var desc = modelInfo.desc ?? "";
    if (desc.isNotEmpty) {
      modelStr += "/// $desc\n";
    }

    /// 类声明所在的那一行
    modelStr += _headerLine(modelInfo, conf);

    /// 属性行
    modelStr += _properties(modelInfo, conf);

    /// 是否有需要映射的属性
    var hasNeedMappingKeyProperties =
        modelInfo.properties
            .where(
              (property) =>
                  property.key !=
                  StringUtils.underscoreToCamelCase(property.key),
            )
            .isNotEmpty;

    /// Codable
    modelStr += _codableMappingLines(
      modelInfo,
      conf,
      hasNeedMappingKeyProperties,
    );

    /// YYModel
    modelStr += _yymodelMappingLines(
      modelInfo,
      conf,
      hasNeedMappingKeyProperties,
    );

    /// 构造方法
    modelStr += _constructionMethod(modelInfo, conf);

    /// 实例方法
    modelStr += _instanceMethod(modelInfo, conf);

    modelStr += "\n}";
    for (var subModelInfo in modelInfo.subModelInfos) {
      if (subModelInfo.sameModelTypeName != null) {
        continue;
      }
      var subModelStr = _modelString(subModelInfo, conf);
      modelStr += "\n\n$subModelStr";
    }
    return modelStr;
  }

  /// 类声明所在的那一行
  static String _headerLine(ModelInfo modelInfo, ConfigurationsModel conf) {
    String headerLine;
    if (conf.isUsingStruct || !conf.supportObjc) {
      headerLine =
          '${conf.isUsingStruct ? "struct" : "class"} ${modelInfo.typeName} {';
      if (conf.supportSmartCodable) {
        headerLine = headerLine.replaceFirst(' {', ': SmartCodable {');
      } else if (conf.originCodable) {
        headerLine = headerLine.replaceFirst(' {', ': Codable {');
      }

      /// 检查是否支持public
      if (conf.supportPublic) {
        headerLine = headerLine.replaceRange(0, 0, "public ");
      }
    } else {
      headerLine = 'class ${modelInfo.typeName}: NSObject {';
      if (conf.supportSmartCodable) {
        headerLine = headerLine.replaceFirst(' {', ', SmartCodable {');
      } else if (conf.originCodable) {
        headerLine = headerLine.replaceFirst(' {', ', Codable {');
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
    return headerLine;
  }

  /// 属性行列
  static String _properties(ModelInfo modelInfo, ConfigurationsModel conf) {
    var propertiesStr = "";
    for (var property in modelInfo.properties) {
      String propertyStr;
      String propertyKey =
          conf.isCamelCase
              ? StringUtils.underscoreToCamelCase(property.key)
              : property.key;
      if (property.desc.isNotEmpty) {
        var propertyDesc = "    /// ${property.desc}";
        propertiesStr += "\n$propertyDesc";
      }
      var varDisplay = conf.supportPublic ? '    public var' : '    var';
      if (property.isList) {
        propertyStr = "$varDisplay $propertyKey: [${property.type}]?";
      } else {
        var propertyTypeDisplay =
            conf.supportObjc &&
                    (property.type == 'Int' || property.type == 'Double')
                ? '${property.type} = 0'
                : (conf.supportObjc && property.type == 'Bool'
                    ? '${property.type} = false'
                    : '${property.type}?');

        propertyStr = "$varDisplay $propertyKey: $propertyTypeDisplay";
      }
      if (property.isUnidentifiedType) {
        propertyStr +=
            " $todoKey 未识别`${property.key}`类型，预设为String，为避免出现程序崩溃，请手动处理";
      }
      if (conf.supportYYModel &&
          StringUtils.isValidBracketString(property.type)) {
        propertyStr +=
            " $todoKey 未识别`${property.key}`在YYModel中的类型，为避免数值为空，请手动处理多维数组的情况";
      }
      propertiesStr += "\n$propertyStr";
    }
    return propertiesStr;
  }

  /// Codable映射相关
  static String _codableMappingLines(
    ModelInfo modelInfo,
    ConfigurationsModel conf,
    bool hasNeedMappingKeyProperties,
  ) {
    var modelStr = "";

    /// 检查SmartCodable要求的映射关系
    if (conf.supportSmartCodable) {
      if (conf.isCamelCase && hasNeedMappingKeyProperties) {
        var mappingStr =
            "\n\n    ${_publicPan(conf)}static func mappingForKey() -> [SmartKeyTransformer]? {\n        return [";
        for (var property in modelInfo.properties) {
          var camelKey = StringUtils.underscoreToCamelCase(property.key);
          if (camelKey == property.key) {
            continue;
          }
          mappingStr +=
              "\n            CodingKeys.$camelKey <--- \"${property.key}\",";
        }
        mappingStr += "\n        ]\n    }";

        modelStr += mappingStr;
      }
      if (!conf.isUsingStruct) {
        if (conf.supportObjc) {
          modelStr +=
              "\n\n    ${_publicPan(conf)}required override init() {\n        super.init()\n    }";
        } else {
          modelStr += "\n\n    ${_publicPan(conf)}required init() {}";
        }
      } else {
        modelStr += "\n\n    ${_publicPan(conf)}init() {}";
      }
    } else if (conf.originCodable) {
      if (conf.isCamelCase && hasNeedMappingKeyProperties) {
        var mappingStr =
            "\n\n    ${_publicPan(conf)}enum CodingKeys: String, CodingKey {";
        for (var property in modelInfo.properties) {
          var camelKey = StringUtils.underscoreToCamelCase(property.key);
          mappingStr += "\n        case $camelKey";
          if (camelKey != property.key) {
            mappingStr += " = \"${property.key}\"";
          }
        }
        mappingStr += "\n    }";
        modelStr += mappingStr;
      }

      if (modelInfo.properties.isNotEmpty) {
        /// 安全反序列化
        var decoderStr =
            "\n\n    ${_publicPan(conf)}${conf.isUsingStruct ? '' : 'required '}init(from decoder: any Decoder) throws {";

        decoderStr +=
            "\n        let container = try decoder.container(keyedBy: CodingKeys.self)";
        for (var property in modelInfo.properties) {
          var camelKey = StringUtils.underscoreToCamelCase(property.key);
          var isList = property.isList;
          var type = property.type;
          var key = conf.isCamelCase ? camelKey : property.key;
          var typeStr = isList ? "[$type]" : type;
          if (!conf.supportObjc ||
              !_isObjcShouldDefaultValueType(type) ||
              property.isList) {
            decoderStr +=
                "\n        self.$key = try? container.decodeIfPresent($typeStr.self, forKey: .$key)";
          } else {
            decoderStr +=
                "\n        self.$key = (try? container.decodeIfPresent($typeStr.self, forKey: .$key)) ?? ${(type == 'Int' || type == 'Double') ? "0" : "false"}";
          }
        }
        if (!conf.isUsingStruct && conf.supportObjc) {
          decoderStr += "\n        super.init()";
        }
        decoderStr += "\n    }";
        modelStr += decoderStr;
      }
    }
    return modelStr;
  }

  /// YYModel的映射数据
  static String _yymodelMappingLines(
    ModelInfo modelInfo,
    ConfigurationsModel conf,
    bool hasNeedMappingKeyProperties,
  ) {
    var modelStr = "";

    if (conf.supportYYModel) {
      /// 是否有数组的子模型属性
      var hasListProperty = false;
      for (int i = 0; i < modelInfo.properties.length; i++) {
        var property = modelInfo.properties[i];
        if (property.isList &&
            !property.isUnidentifiedType &&
            !_isBasicType(property.type) &&
            !property.type.startsWith("[")) {
          hasListProperty = true;
          break;
        }
      }
      if (hasListProperty) {
        var mappingStr =
            "\n\n    ${_publicPan(conf)}static func modelContainerPropertyGenericClass() -> [String : Any]? {\n        return [";
        for (var property in modelInfo.properties) {
          if (_isBasicType(property.type) ||
              !property.isList ||
              property.type.startsWith("[")) {
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
            "\n\n    ${_publicPan(conf)}static func modelCustomPropertyMapper() -> [String : Any]? {\n        return [";
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
    return modelStr;
  }

  /// 构造方法
  static String _constructionMethod(
    ModelInfo modelInfo,
    ConfigurationsModel conf,
  ) {
    var modelStr = "";
    if (conf.supportConstruction && modelInfo.properties.isNotEmpty) {
      String conStr = "\n\n    ${_publicPan(conf)}init(";
      String propertieRows = "";
      for (int i = 0; i < modelInfo.properties.length; i += 1) {
        var property = modelInfo.properties[i];
        var key =
            conf.isCamelCase
                ? StringUtils.underscoreToCamelCase(property.key)
                : property.key;
        var isList = property.isList;
        var type = property.type;
        conStr += "$key: ";
        conStr += isList ? "[$type]" : type;
        if (!conf.supportObjc || !_isObjcShouldDefaultValueType(type)) {
          conStr += "?";
        }
        if (i < modelInfo.properties.length - 1) {
          conStr += ", ";
        }
        propertieRows += "\n        self.$key = $key";
      }
      conStr += ") {";
      if (conf.supportObjc) {
        conStr += "\n        super.init()";
      }
      conStr += propertieRows;
      conStr += "\n    }";
      modelStr += conStr;
    }
    return modelStr;
  }

  /// 生成Objc可以调用的SmartCodable实例方法
  static String _instanceMethod(ModelInfo modelInfo, ConfigurationsModel conf) {
    var modelStr = "";
    final objcSupportPan = conf.supportObjc ? "@objc " : "";
    if (conf.objcObjcDeserialization) {
      if (conf.supportSmartCodable) {
        var deserializationSingle =
            "\n    $objcSupportPan${_publicPan(conf)}static func instance(from value: Any?) -> ${modelInfo.typeName}? {";
        deserializationSingle +=
            "\n        guard let dictionary = value as? [String: Any] else { return nil }";
        deserializationSingle +=
            "\n        return ${modelInfo.typeName}.deserialize(from: dictionary)\n    }";
        modelStr += "\n$deserializationSingle";

        var deserializationArray =
            "\n    $objcSupportPan${_publicPan(conf)}static func instances(from value: Any?) -> [${modelInfo.typeName}]? {";
        deserializationArray +=
            "\n        guard let array = value as? [Any] else { return nil }";
        deserializationArray +=
            "\n        return [${modelInfo.typeName}].deserialize(from: array)\n    }";
        modelStr += "\n$deserializationArray";
      } else if (conf.originCodable) {
        var deserializationSingle =
            "\n    $objcSupportPan${_publicPan(conf)}static func instance(from value: Any?) -> ${modelInfo.typeName}? {";
        deserializationSingle +=
            "\n        guard let dictionary = value as? [String: Any] else { return nil }\n        guard let data = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }\n        return try? JSONDecoder().decode(${modelInfo.typeName}.self, from: data)\n    }";
        modelStr += "\n$deserializationSingle";

        var deserializationArray =
            "\n    $objcSupportPan${_publicPan(conf)}static func instances(from value: Any?) -> [${modelInfo.typeName}]? {";
        deserializationArray +=
            "\n        guard let array = value as? [Any] else { return nil }\n        guard let data = try? JSONSerialization.data(withJSONObject: array) else { return nil }\n        return try? JSONDecoder().decode([${modelInfo.typeName}].self, from: data)\n    }";
        modelStr += "\n$deserializationArray";
      }
    }
    return modelStr;
  }
}
