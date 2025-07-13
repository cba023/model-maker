import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// 是否是Mate项目
  bool _isMate = false;

  /// 支持构造方法
  bool _supportConstruction = false;

  /// 原生Codable
  bool _originCodable = false;

  /// codable和SmartCodable开关
  bool _codableMap = true;

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
  bool get isMate => _isMate;
  bool get supportConstruction => _supportConstruction;

  bool get originCodable => _originCodable;

  bool get codableMap => _codableMap;

  // Setter 方法 - 修改值并通知监听器
  set supportSmartCodable(bool value) {
    if (_supportSmartCodable != value) {
      _supportSmartCodable = value;
      if (!value) {
        if (!originCodable) {
          _objcObjcDeserialization = false;
        }
      } else {
        _originCodable = false;
      }
      notifyListeners();
    }
  }

  set codableMap(bool value) {
    if (_codableMap != value) {
      _codableMap = value;
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
        if (originCodable) {
          _supportSmartCodable = false;
        } else {
          _supportSmartCodable = true;
          _originCodable = false;
        }
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

  set isMate(bool value) {
    if (_isMate != value) {
      _isMate = value;
      saveIsMate(value);
      notifyListeners();
    }
  }

  set supportConstruction(bool value) {
    if (_supportConstruction != value) {
      _supportConstruction = value;
      notifyListeners();
    }
  }

  set originCodable(bool value) {
    if (_originCodable != value) {
      _originCodable = value;
      if (value) {
        _supportSmartCodable = false;
      } else {
        if (!_supportSmartCodable) {
          _objcObjcDeserialization = false;
        }
      }
      notifyListeners();
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

  Function(bool)? _isMateChanged;
  void setIsMateChanged(Function(bool) callback) {
    _isMateChanged = callback;
  }

  /// 从本地去读取是否是mate项目,并把状态更新到页面上
  Future<void> uploadIsMate() async {
    final prefs = await SharedPreferences.getInstance();
    final isMate = prefs.getBool("isMate");
    if (isMate != null && isMate == true) {
      this.isMate = isMate;
      _isMateChanged?.call(isMate);
    }
  }

  /// 把isMate状态存入本地
  Future<void> saveIsMate(bool isMate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMate', isMate);
  }
}
