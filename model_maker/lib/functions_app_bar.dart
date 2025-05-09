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
  // bool supportSmartCodable = true;
  // bool isCamelCase = true;
  // bool supportObjc = true;
  // bool isUsingStruct = false;
  // bool supportYYModel = true;
  // bool supportPublic = true;
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
            runSpacing: 40,
            children: [
              // TextField(minLines: 1),
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
        ],
      ),
    );
  }
}
