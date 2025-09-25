import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_maker/checkbox_with_text.dart';
import 'package:model_maker/configurations_model.dart';
import 'package:model_maker/string_utils.dart';
import 'package:provider/provider.dart';

class FunctionsAppBar extends StatefulWidget {
  const FunctionsAppBar({super.key});

  @override
  State<FunctionsAppBar> createState() => _FunctionsAppBarState();
}

class _FunctionsAppBarState extends State<FunctionsAppBar> {
  var textEditingController = TextEditingController();
  late ConfigurationsModel _confModel;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _confModel = context.read<ConfigurationsModel>();
    _confModel.setIsMateChanged((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final confModel = Provider.of<ConfigurationsModel>(context, listen: false);
    confModel.uploadIsMate();

    final buttonWidth = 90.0;

    /// 粘贴按钮
    final pasteWidget = Container(
      margin: EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () {
          _readClipboard().then((value) {
            confModel.pastedJsonString = value ?? "";
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade100,
          foregroundColor: Colors.orange.shade800,
          elevation: 2,
          shadowColor: Colors.orange.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade300, width: 1),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          minimumSize: Size(buttonWidth, 80),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.paste, size: 20),
            SizedBox(height: 4),
            Text(
              '粘贴',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    final inputNameWidget = Container(
      margin: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '配置模型名称',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: TextField(
                    maxLines: 1,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "请输入根模型名，默认Root",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    controller: textEditingController,
                    onChanged: (value) {
                      setState(() {
                        confModel.modelName = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    /// 中间内容
    Widget buildCenterContent(bool isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Wrap(
          spacing: isMobile ? 8 : 16,
          runSpacing: isMobile ? 8 : 12,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxWithText(
                    text: '使用驼峰命名',
                    value: confModel.isCamelCase,
                    onChanged: (value) {
                      setState(() {
                        confModel.isCamelCase = value ?? true;
                      });
                    },
                  ),
                  CheckboxWithText(
                    text: '使用结构体',
                    value: confModel.isUsingStruct,
                    onChanged: (value) {
                      setState(() {
                        confModel.isUsingStruct = value ?? true;
                      });
                    },
                  ),
                  CheckboxWithText(
                    text: '支持Objective-C',
                    value: confModel.supportObjc,
                    onChanged: (value) {
                      setState(() {
                        confModel.supportObjc = value ?? true;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 185),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxWithText(
                    text: '支持SmartCodable',
                    value: confModel.supportSmartCodable,
                    onChanged: (value) {
                      setState(() {
                        confModel.supportSmartCodable = value ?? true;
                      });
                    },
                  ),
                  CheckboxWithText(
                    text: '原生Codable',
                    value: confModel.originCodable,
                    onChanged: (value) {
                      setState(() {
                        confModel.originCodable = value ?? true;
                      });
                    },
                  ),
                  CheckboxWithText(
                    text: '(Smart)Codable映射',
                    value: confModel.codableMap,
                    onChanged: (value) {
                      setState(() {
                        confModel.codableMap = value ?? true;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 170),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxWithText(
                    text: '支持YYModel',
                    value: confModel.supportYYModel,
                    onChanged: (value) {
                      setState(() {
                        confModel.supportYYModel = value ?? true;
                      });
                    },
                  ),
                  CheckboxWithText(
                    text: '支持public',
                    value: confModel.supportPublic,
                    onChanged: (value) {
                      setState(() {
                        confModel.supportPublic = value ?? true;
                      });
                    },
                  ),
                  CheckboxWithText(
                    text: '反序列化静态方法',
                    value: confModel.objcObjcDeserialization,
                    onChanged: (value) {
                      setState(() {
                        confModel.objcObjcDeserialization = value ?? true;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxWithText(
                    text: 'B类接口文档',
                    value: confModel.isMate,
                    onChanged: (value) {
                      setState(() {
                        confModel.isMate = value ?? false;
                      });
                    },
                  ),
                  CheckboxWithText(
                    text: '生成构造方法',
                    value: confModel.supportConstruction,
                    onChanged: (value) {
                      setState(() {
                        confModel.supportConstruction = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    /// 复制按钮
    final copyWidget = Container(
      margin: EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () {
          _copyToClipboard(context, outputResult ?? "");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade100,
          foregroundColor: Colors.green.shade800,
          elevation: 2,
          shadowColor: Colors.green.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green.shade300, width: 1),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          minimumSize: Size(buttonWidth, 80),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copy, size: 20),
            SizedBox(height: 4),
            Text(
              '复制',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth;

        // 更细致的屏幕尺寸断点
        final bool isMobile =
            containerWidth >= 480 && containerWidth < 768; // 手机
        final bool isTablet =
            containerWidth >= 768 && containerWidth < 1200; // 平板
        final bool isDesktop = containerWidth >= 1200; // 桌面

        // 根据屏幕尺寸选择布局
        if (isDesktop) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  pasteWidget,
                  SizedBox(width: 240, child: inputNameWidget),
                  buildCenterContent(false),
                  Spacer(),
                  copyWidget,
                ],
              ),
            ),
          );
        } else if (isTablet) {
          // 平板端布局 - 三行布局
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：按钮和模型名称
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      pasteWidget,
                      SizedBox(width: 8),
                      Expanded(child: inputNameWidget),
                      SizedBox(width: 8),
                      copyWidget,
                    ],
                  ),
                  SizedBox(height: 8),
                  // 第二行：复选框区域
                  buildCenterContent(false),
                ],
              ),
            ),
          );
        } else if (isMobile) {
          // 手机端布局
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：按钮
                  Row(
                    children: [
                      Expanded(child: pasteWidget),
                      SizedBox(width: 6),
                      Expanded(child: copyWidget),
                    ],
                  ),
                  SizedBox(height: 8),
                  // 第二行：模型名称
                  inputNameWidget,
                  SizedBox(height: 6),
                  // 第三行：复选框区域
                  buildCenterContent(true),
                ],
              ),
            ),
          );
        } else {
          // 小手机端布局 - 最紧凑的垂直布局
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：按钮
                  Row(
                    children: [
                      Expanded(child: pasteWidget),
                      SizedBox(width: 4),
                      Expanded(child: copyWidget),
                    ],
                  ),
                  SizedBox(height: 6),
                  // 第二行：模型名称
                  inputNameWidget,
                  SizedBox(height: 4),
                  // 第三行：复选框区域
                  buildCenterContent(true),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  /// 将文本复制到剪贴板
  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    var hint = "复制成功！";
    var todosCount = StringUtils.countofTodo(text);
    if (todosCount > 0) {
      hint += "注意有$todosCount处TODO项,可能是未识别类型，为避免出现程序崩溃或取不到值的情况，请手动处理";
      _showDialog(context, hint);
    } else {
      // 显示复制成功的提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hint), duration: Duration(seconds: 1)),
      );
    }
  }

  /// 读取剪切板
  Future<String?> _readClipboard() async {
    try {
      // 获取剪贴板数据
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已粘贴剪贴板内容'), duration: Duration(seconds: 1)),
        );
        return clipboardData.text ?? "";
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('剪贴板为空'), duration: Duration(seconds: 1)),
        );
        return null;
      }
    } catch (e) {
      // 处理异常
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('读取剪贴板失败: $e'), duration: Duration(seconds: 1)),
      );
      return null;
    }
  }

  /// 显示弹窗
  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '温馨提示',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            '我知道了',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
