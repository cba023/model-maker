import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_maker/json_tool.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<_SplitWindowState> _childKey = GlobalKey();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    loadJsonData();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('模型生成器'),
          actions: [
            ElevatedButton(
              onPressed: () {
                _generateModels(context);
              },
              child: Text('生成'),
            ),
          ],
        ),
        body: SplitWindow(key: _childKey),
      ),
    );
  }

  Future<void> loadJsonData() async {
    try {
      // 读取 JSON 文件内容
      String jsonString = await rootBundle.loadString(
        'assets/defaultText.json',
      );
      _childKey.currentState?.textEditingController.text = jsonString;
    } catch (e) {
      print('读取 JSON 文件时出错: $e');
    }
  }

  /// 转换成Map对象
  void _generateModels(BuildContext context) {
    String? jsonStr = _childKey.currentState?.textEditingController.text;
    String? resultStr = JsonTool.generateModels(jsonStr);
    _childKey.currentState?.textResultController.text = resultStr ?? "";
  }
}

class SplitWindow extends StatefulWidget {
  const SplitWindow({super.key});
  @override
  _SplitWindowState createState() => _SplitWindowState();
}

class _SplitWindowState extends State<SplitWindow> {
  double _splitPosition = 0.5; // 初始分割位置为中间
  final double _centerSeplineWidth = 12;
  var textEditingController = TextEditingController();
  var textResultController = TextEditingController();

  void _updateSplitPosition(Offset position) {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _splitPosition = position.dx / screenWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) {
            _updateSplitPosition(details.localPosition);
          },
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: constraints.maxWidth * _splitPosition,
                child: Container(
                  color: Colors.black12,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: double.infinity,
                        minWidth: double.infinity,
                      ),
                      child: TextField(
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "请在此处输入json文本",
                          border: InputBorder.none,
                        ),
                        controller: textEditingController,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: constraints.maxWidth * _splitPosition,
                top: 0,
                bottom: 0,
                width: _centerSeplineWidth,
                // 分隔条宽度
                child: Container(
                  color: Colors.grey,
                  child: Center(
                    child: Icon(
                      Icons.drag_handle,
                      size: _centerSeplineWidth * 0.8,
                    ),
                  ),
                ),
              ),
              Positioned(
                left:
                    constraints.maxWidth * _splitPosition + _centerSeplineWidth,
                top: 0,
                bottom: 0,
                width:
                    constraints.maxWidth * (1 - _splitPosition) -
                    _centerSeplineWidth,
                child: Container(
                  color: Color.fromARGB(255, 204, 249, 205),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: double.infinity,
                        minWidth: double.infinity,
                      ),
                      child: TextField(
                        readOnly: true,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "模型类生成后显示在此处",
                          border: InputBorder.none,
                        ),
                        controller: textResultController,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
