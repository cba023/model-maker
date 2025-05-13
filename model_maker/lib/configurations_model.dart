import 'package:flutter/material.dart';

/// 配置信息
class ConfigurationsModel extends ChangeNotifier {
  bool supportSmartCodable = true;
  bool isCamelCase = true;
  bool supportObjc = true;
  bool isUsingStruct = false;
  bool supportYYModel = false;
  bool supportPublic = false;
  String modelName = "Root";
}
