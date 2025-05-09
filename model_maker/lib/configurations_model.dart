import 'package:flutter/material.dart';

class ConfigurationsModel extends ChangeNotifier {
  bool supportSmartCodable = true;
  bool isCamelCase = true;
  bool supportObjc = true;
  bool isUsingStruct = false;
  bool supportYYModel = false;
  bool supportPublic = false;
  String modelName = "";
}
