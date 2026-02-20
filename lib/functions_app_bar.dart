import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_maker/checkbox_with_text.dart';
import 'package:model_maker/configurations_model.dart';
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
    _confModel.uploadIsMate();
  }

  @override
  Widget build(BuildContext context) {
    final confModel = Provider.of<ConfigurationsModel>(context, listen: false);

    final buttonWidth = 90.0;
    final componentHeight = 100.0; // 统一的高度变量，供所有组件使用

    /// 粘贴按钮
    Widget buildPasteWidget(bool isMobile) {
      return Container(
        margin: EdgeInsets.all(0),
        child: ElevatedButton(
          onPressed: () {
            _readClipboard().then((value) {
              confModel.pastedJsonString = value ?? "";
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade100,
            foregroundColor: Colors.orange.shade800,
            elevation: 0,
            shadowColor: Colors.orange.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange.shade300, width: 1),
            ),
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            minimumSize: Size(buttonWidth, componentHeight), // 使用统一高度变量
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
    }

    /// 输入名称组件
    Widget buildInputNameWidget(bool isMobile) {
      return Container(
        margin: EdgeInsets.all(0),
        height: componentHeight, // 使用统一高度变量
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
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
            padding: EdgeInsets.all(10), // 固定内边距，所有屏幕保持一致
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 改为居中布局
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8), // 减少顶部间距
                Text(
                  '配置模型名称',
                  style: TextStyle(
                    fontSize: 13, // 稍微减小字体大小
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    height: 1.1, // 设置行高
                  ),
                ),
                SizedBox(height: 12), // 减少间距
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 11, // 固定内边距，所有屏幕保持一致
                      ),
                      child: TextField(
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14, // 固定字体大小，所有屏幕保持一致
                          height: 1.2, // 设置行高，确保文本完全可见
                        ),
                        decoration: InputDecoration(
                          hintText: "请输入根模型名，默认Root",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14, // 固定字体大小，所有屏幕保持一致
                            height: 1.2, // 设置提示文本行高
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1, // 减少垂直内边距，给文本更多空间
                            horizontal: 4,
                          ),
                          isDense: true, // 减少内部间距
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
                ),
                SizedBox(height: 3), // 减少底部间距，给输入框更多空间
              ],
            ),
          ),
        ),
      );
    }

    /// 中间内容
    Widget buildCenterContent(bool isMobile) {
      return Container(
        width: double.infinity, // 填满可用宽度
        height: isMobile ? 160 : componentHeight, // 手机端160px，大屏中屏使用统一高度变量
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
        padding: EdgeInsets.fromLTRB(2, 10, 2, 2), // 调整内边距以适应不同高度
        child: Wrap(
          direction: Axis.vertical, // 垂直方向实现列式布局
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 8, // 垂直间距（行间距）
          runSpacing: 8, // 水平间距（列间距）
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
              text: '生成构造方法',
              value: confModel.supportConstruction,
              onChanged: (value) {
                setState(() {
                  confModel.supportConstruction = value ?? false;
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
            CheckboxWithText(
              text: 'Swagger接口文档',
              value: confModel.isMate,
              onChanged: (value) {
                setState(() {
                  confModel.isMate = value ?? false;
                });
              },
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth;

        // 更细致的屏幕尺寸断点
        final bool isSmallMobile = containerWidth < 480; // 小手机
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
                colors: [
                  Colors.blue.shade50,
                  Colors.cyan.shade50,
                  Colors.purple.shade50,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade50, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: componentHeight, // 使用统一高度变量
                    child: buildPasteWidget(false),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    height: componentHeight, // 使用统一高度变量
                    width: 240,
                    child: buildInputNameWidget(false),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: buildCenterContent(false)),
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
                colors: [
                  Colors.blue.shade50,
                  Colors.cyan.shade50,
                  Colors.purple.shade50,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade50, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
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
                  // 第一行：按钮和模型名称
                  SizedBox(
                    height: componentHeight, // 使用统一高度变量
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildPasteWidget(false),
                        SizedBox(width: 8),
                        Expanded(child: buildInputNameWidget(false)),
                      ],
                    ),
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
                colors: [
                  Colors.blue.shade50,
                  Colors.cyan.shade50,
                  Colors.purple.shade50,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade50, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
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
                  // 第一行：按钮和模型名称
                  SizedBox(
                    height: componentHeight, // 使用统一高度变量
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildPasteWidget(true),
                        SizedBox(width: 8),
                        Expanded(child: buildInputNameWidget(true)),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  // 第二行：复选框区域
                  buildCenterContent(true),
                ],
              ),
            ),
          );
        } else if (isSmallMobile) {
          // 小手机端布局 - 最紧凑的垂直布局
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.cyan.shade50,
                  Colors.purple.shade50,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade50, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
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
                  // 第一行：按钮和模型名称
                  SizedBox(
                    height: componentHeight, // 使用统一高度变量
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildPasteWidget(true),
                        SizedBox(width: 6),
                        Expanded(child: buildInputNameWidget(true)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  // 第二行：复选框区域
                  buildCenterContent(true),
                ],
              ),
            ),
          );
        } else {
          // 默认布局 - 小手机布局
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.cyan.shade50,
                  Colors.purple.shade50,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade50, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
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
                  // 第一行：按钮和模型名称
                  SizedBox(
                    height: componentHeight, // 使用统一高度变量
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildPasteWidget(true),
                        SizedBox(width: 6),
                        Expanded(child: buildInputNameWidget(true)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  // 第二行：复选框区域
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
}
