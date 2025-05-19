import 'package:flutter/material.dart';

final defaultModelName = "Root";

String? outputResult;

/// 配置信息
class ConfigurationsModel extends ChangeNotifier {
  // 私有变量存储实际值
  bool _supportSmartCodable = true;
  bool _isCamelCase = true;
  bool _supportObjc = true;
  bool _isUsingStruct = false;
  bool _supportYYModel = false;
  bool _supportPublic = false;

  /// 基于SmartCodable的objc反序列化方法
  bool _objcObjcDeserialization = false;
  String _modelName = "";
  String _pastedJsonString = "";

  // Getter 方法
  bool get supportSmartCodable => _supportSmartCodable;
  bool get isCamelCase => _isCamelCase;
  bool get supportObjc => _supportObjc;
  bool get isUsingStruct => _isUsingStruct;
  bool get supportYYModel => _supportYYModel;
  bool get supportPublic => _supportPublic;
  bool get objcObjcDeserialization => _objcObjcDeserialization;
  String get modelName => _modelName;
  String get pastedJsonString => _pastedJsonString;

  // Setter 方法 - 修改值并通知监听器
  set supportSmartCodable(bool value) {
    if (_supportSmartCodable != value) {
      _supportSmartCodable = value;
      notifyListeners();
    }
  }

  set isCamelCase(bool value) {
    if (_isCamelCase != value) {
      _isCamelCase = value;
      notifyListeners();
    }
  }

  set supportObjc(bool value) {
    if (_supportObjc != value) {
      _supportObjc = value;
      if (value) {
        _isUsingStruct = false;
      } else {
        _supportYYModel = false;
      }
      notifyListeners();
    }
  }

  set isUsingStruct(bool value) {
    if (_isUsingStruct != value) {
      _isUsingStruct = value;
      if (value) {
        _supportYYModel = false;
        _supportObjc = false;
        _objcObjcDeserialization = false;
      }
      notifyListeners();
    }
  }

  set supportYYModel(bool value) {
    if (_supportYYModel != value) {
      _supportYYModel = value;
      if (value) {
        _supportObjc = true;
        _isUsingStruct = false;
      }
      notifyListeners();
    }
  }

  set supportPublic(bool value) {
    if (_supportPublic != value) {
      _supportPublic = value;
      notifyListeners();
    }
  }

  set objcObjcDeserialization(bool value) {
    if (_objcObjcDeserialization != value) {
      _objcObjcDeserialization = value;
      if (value) {
        _supportObjc = true;
        _isUsingStruct = false;
        _supportSmartCodable = true;
      }
      notifyListeners();
    }
  }

  set modelName(String value) {
    if (_modelName != value) {
      _modelName = value;
      notifyListeners();
    }
  }

  set pastedJsonString(String value) {
    if (_pastedJsonString != value) {
      _pastedJsonString = value;
      _onPastedJsonStringChanged?.call(value);
    }
  }

  void resetpastedJsonString() {
    if (_pastedJsonString.isNotEmpty) {
      _pastedJsonString = "";
    }
  }

  Function(String)? _onPastedJsonStringChanged;

  // 设置 JSON 字符串变化回调
  void setOnPastedJsonStringChanged(Function(String) callback) {
    _onPastedJsonStringChanged = callback;
  }

  // 重置所有配置为默认值
  void reset() {
    _supportSmartCodable = true;
    _isCamelCase = true;
    _supportObjc = true;
    _isUsingStruct = false;
    _supportYYModel = false;
    _supportPublic = false;
    _objcObjcDeserialization = false;
    _modelName = defaultModelName;
    _pastedJsonString = "";
    notifyListeners();
  }
}
