import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_maker/checkbox_with_text.dart';
import 'package:model_maker/configurations_model.dart';
import 'package:provider/provider.dart';

class FunctionsAppBar extends StatefulWidget {
  final ValueChanged<String>? onDataPasted; // 定义回调函数

  const FunctionsAppBar({Key? key, this.onDataPasted}) : super(key: key);

  @override
  State<FunctionsAppBar> createState() => _FunctionsAppBarState();
}

class _FunctionsAppBarState extends State<FunctionsAppBar> {
  var textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var topHeight = 100.0;
    final confModel = Provider.of<ConfigurationsModel>(context, listen: false);
    return Container(
      height: topHeight,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: MaterialButton(
              onPressed: () {
                _readClipboard().then((value) {
                  if (value != null) {
                    widget.onDataPasted?.call(value);
                  }
                  ;
                });
              },
              child: const Icon(Icons.paste),
              color: Colors.redAccent,
              height: double.infinity,
            ),
          ),
          SizedBox(
            width: 300,
            height: double.infinity,
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Container(
                  color: Colors.yellowAccent,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 1),
                        Text('配置模型名称:', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 6),
                        Container(
                          color: Colors.white60,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(6, 1, 6, 1),
                            child: TextField(
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: "请输入根模型名，默认Root",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
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
              ),
            ),
          ),
          Wrap(
            direction: Axis.vertical,
            runSpacing: 30,
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
                text: '支持Objc',
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
            ],
          ),
          Expanded(child: Spacer()),

          Padding(
            padding: EdgeInsets.all(4),
            child: MaterialButton(
              onPressed: () {
                _copyToClipboard(context, outputResult ?? "");
              },
              child: const Icon(Icons.copy),
              color: Colors.greenAccent,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  // 将文本复制到剪贴板
  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    // 显示复制成功的提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('复制成功！'), duration: Duration(seconds: 1)),
    );
  }

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
