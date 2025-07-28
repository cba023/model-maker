/// 模型信息
class ModelInfo {
  ModelInfo(
    this.originKey,
    this.value,
    this.typeName,
    this.subModelInfos,
    this.properties,
    this.desc,
    this.sameModelTypeName,
  );

  /// 默认key
  String? originKey;

  /// 内容值
  dynamic value;

  String typeName;

  String? desc;

  List<ModelInfo> subModelInfos;
  List<PropertyInfo> properties;

  /// 重复的模型名
  String? sameModelTypeName;
}

/// 属性信息
class PropertyInfo {
  PropertyInfo(
    this.key,
    this.type,
    this.isList,
    this.isBasicType,
    this.desc,
    this.typeFromMarkdown, [
    this.isUnidentifiedType = false,
  ]);
  String key;
  String type;
  bool isList;
  bool isBasicType;
  String desc;
  String typeFromMarkdown;
  bool isUnidentifiedType;
}
