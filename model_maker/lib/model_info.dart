class ModelInfo {
  ModelInfo(
    this.originKey,
    this.value,
    this.typeName,
    this.subModelInfos,
    this.properties,
  );

  /// 默认key
  String? originKey;

  /// 内容值
  dynamic value;

  String typeName;

  List<ModelInfo> subModelInfos;
  List<PropertyInfo> properties;
}

class PropertyInfo {
  PropertyInfo(this.key, this.type, this.isList);
  String key;
  String type;
  bool isList;
}
