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
  @override
  Widget build(BuildContext context) {
    var topHeight = 100.0;
    final confModel = Provider.of<ConfigurationsModel>(context, listen: false);
    return Container(
      height: topHeight,
      child: Row(
        children: [
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
          Padding(
            padding: EdgeInsets.all(4),
            child: MaterialButton(
              onPressed: () {
                _copyToClipboard(context, textEditingController.text);
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
}
