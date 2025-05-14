import 'package:flutter/material.dart';
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
    final confModel = Provider.of<ConfigurationsModel>(context, listen: false);
    return Container(
      height: 120,
      // decoration: BoxDecoration(color: Colors.grey[200]),
      child: Row(
        children: [
          Wrap(
            direction: Axis.vertical,
            runSpacing: 30,
            children: [
              SizedBox(
                width: 220,
                height: 30,
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "请设置根模型名，默认Root",
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
                    if (confModel.isUsingStruct) {
                      confModel.supportObjc = false;
                      confModel.supportYYModel = false;
                    }
                  });
                },
              ),
              CheckboxWithText(
                text: '支持Objc',
                value: confModel.supportObjc,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      confModel.isUsingStruct = false;
                    } else {
                      confModel.supportYYModel = false;
                    }
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
                    if (value == true) {
                      confModel.supportObjc = true;
                      confModel.isUsingStruct = false;
                    }
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
        ],
      ),
    );
  }
}
