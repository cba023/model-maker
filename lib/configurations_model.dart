import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final defaultModelName = "Root";

String? outputResult;

/// 配置信息
class ConfigurationsModel extends ChangeNotifier {
  Timer? _saveTimer;

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
    _updateBoolField(
      _supportSmartCodable,
      value,
      (newValue) {
        _supportSmartCodable = newValue;
        if (!newValue) {
          if (!originCodable) {
            _objcObjcDeserialization = false;
          }
        } else {
          _originCodable = false;
        }
      },
    );
  }

  set codableMap(bool value) {
    _updateBoolField(_codableMap, value, (newValue) => _codableMap = newValue);
  }

  set isCamelCase(bool value) {
    _updateBoolField(_isCamelCase, value, (newValue) => _isCamelCase = newValue);
  }

  set supportObjc(bool value) {
    _updateBoolField(
      _supportObjc,
      value,
      (newValue) {
        _supportObjc = newValue;
        if (newValue) {
          _isUsingStruct = false;
        } else {
          _supportYYModel = false;
        }
      },
    );
  }

  set isUsingStruct(bool value) {
    _updateBoolField(
      _isUsingStruct,
      value,
      (newValue) {
        _isUsingStruct = newValue;
        if (newValue) {
          _supportYYModel = false;
          _supportObjc = false;
        }
      },
    );
  }

  set supportYYModel(bool value) {
    _updateBoolField(
      _supportYYModel,
      value,
      (newValue) {
        _supportYYModel = newValue;
        if (newValue) {
          _supportObjc = true;
          _isUsingStruct = false;
        }
      },
    );
  }

  set supportPublic(bool value) {
    _updateBoolField(_supportPublic, value, (newValue) => _supportPublic = newValue);
  }

  set objcObjcDeserialization(bool value) {
    _updateBoolField(
      _objcObjcDeserialization,
      value,
      (newValue) {
        _objcObjcDeserialization = newValue;
        if (newValue) {
          if (originCodable) {
            _supportSmartCodable = false;
          } else {
            _supportSmartCodable = true;
            _originCodable = false;
          }
        }
      },
    );
  }

  set modelName(String value) {
    _updateStringField(_modelName, value, (newValue) => _modelName = newValue);
  }

  set pastedJsonString(String value) {
    if (_pastedJsonString != value) {
      _pastedJsonString = value;
      _scheduleSave();
      _onPastedJsonStringChanged?.call(value);
    }
  }

  set isMate(bool value) {
    _updateBoolField(_isMate, value, (newValue) => _isMate = newValue);
  }

  set supportConstruction(bool value) {
    _updateBoolField(_supportConstruction, value, (newValue) => _supportConstruction = newValue);
  }

  set originCodable(bool value) {
    _updateBoolField(
      _originCodable,
      value,
      (newValue) {
        _originCodable = newValue;
        if (newValue) {
          _supportSmartCodable = false;
        } else {
          if (!_supportSmartCodable) {
            _objcObjcDeserialization = false;
          }
        }
      },
    );
  }

  void resetpastedJsonString() {
    if (_pastedJsonString.isNotEmpty) {
      _pastedJsonString = "";
      _scheduleSave();
    }
  }

  Function(String)? _onPastedJsonStringChanged;

  void setOnPastedJsonStringChanged(Function(String) callback) {
    _onPastedJsonStringChanged = callback;
  }

  Function(bool)? _isMateChanged;

  void setIsMateChanged(Function(bool) callback) {
    _isMateChanged = callback;
  }

  Future<void> uploadIsMate() async {
    final prefs = await SharedPreferences.getInstance();
    final isMate = prefs.getBool("isMate");
    if (isMate != null && isMate == true) {
      _isMate = isMate;
      _isMateChanged?.call(isMate);
    }
  }

  void _updateBoolField(bool currentValue, bool newValue, void Function(bool) updateFunc) {
    if (currentValue != newValue) {
      updateFunc(newValue);
      _scheduleSave();
      notifyListeners();
    }
  }

  void _updateStringField(String currentValue, String newValue, void Function(String) updateFunc) {
    if (currentValue != newValue) {
      updateFunc(newValue);
      _scheduleSave();
      notifyListeners();
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      saveAllConfigurations();
    });
  }

  Future<void> saveAllConfigurations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('supportSmartCodable', _supportSmartCodable);
    await prefs.setBool('isCamelCase', _isCamelCase);
    await prefs.setBool('supportObjc', _supportObjc);
    await prefs.setBool('isUsingStruct', _isUsingStruct);
    await prefs.setBool('supportYYModel', _supportYYModel);
    await prefs.setBool('supportPublic', _supportPublic);
    await prefs.setBool('objcObjcDeserialization', _objcObjcDeserialization);
    await prefs.setString('modelName', _modelName);
    await prefs.setString('pastedJsonString', _pastedJsonString);
    await prefs.setBool('isMate', _isMate);
    await prefs.setBool('supportConstruction', _supportConstruction);
    await prefs.setBool('originCodable', _originCodable);
    await prefs.setBool('codableMap', _codableMap);
  }

  Future<void> loadAllConfigurations() async {
    final prefs = await SharedPreferences.getInstance();
    
    _supportSmartCodable = prefs.getBool('supportSmartCodable') ?? true;
    _isCamelCase = prefs.getBool('isCamelCase') ?? true;
    _supportObjc = prefs.getBool('supportObjc') ?? true;
    _isUsingStruct = prefs.getBool('isUsingStruct') ?? false;
    _supportYYModel = prefs.getBool('supportYYModel') ?? false;
    _supportPublic = prefs.getBool('supportPublic') ?? false;
    _objcObjcDeserialization = prefs.getBool('objcObjcDeserialization') ?? false;
    _modelName = prefs.getString('modelName') ?? "";
    _pastedJsonString = prefs.getString('pastedJsonString') ?? "";
    _isMate = prefs.getBool('isMate') ?? false;
    _supportConstruction = prefs.getBool('supportConstruction') ?? false;
    _originCodable = prefs.getBool('originCodable') ?? false;
    _codableMap = prefs.getBool('codableMap') ?? true;
    
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
