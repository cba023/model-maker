import 'package:flutter/material.dart';
import 'package:model_maker/configurations_model.dart';
import 'package:model_maker/functions_app_bar.dart';
import 'package:model_maker/json_tool.dart';
import 'package:model_maker/debouncer.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ConfigurationsModel(),
      child: MaterialApp(home: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(appBar: _buildAppBar(), body: SplitWindow(key: key)),
    );
  }

  /// appBar
  AppBar _buildAppBar() {
    double height = 115;
    return AppBar(
      backgroundColor: Colors.blueGrey,
      toolbarHeight: height,
      elevation: 0,
      title: FunctionsAppBar(),
    );
  }
}

/// 分体窗口
class SplitWindow extends StatefulWidget {
  const SplitWindow({super.key});
  @override
  _SplitWindowState createState() => _SplitWindowState();
}

class _SplitWindowState extends State<SplitWindow> {
  final Debouncer _debouncer = Debouncer(Duration(seconds: 1));
  double _splitPosition = 0.5; // 初始分割位置为中间

  final double _centerSeplineWidth = 12;
  var textEditingController = TextEditingController();
  var textResultController = TextEditingController();
  late ConfigurationsModel _confModel;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _confModel = context.read<ConfigurationsModel>();
    _confModel.setOnPastedJsonStringChanged((value) {
      textEditingController.text = value;
      _handleConfChange();
    });
    _confModel.addListener(_handleConfChange);
  }

  /// 配置变更后刷新页面数据
  void _handleConfChange() {
    _debouncer.run(() {
      JsonTool.asyncGenerateModels(textEditingController.text, _confModel)
          .then((data) {
            setState(() {
              textResultController.text = data ?? '';
              outputResult = textResultController.text;
            });
          }) // 成功回调
          .catchError((error) => print('错误: $error')) // 错误回调
          .whenComplete(() => print('操作完成')); // 最终回调
    });
  }

  void _updateSplitPosition(Offset position) {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      double dx = position.dx;
      double anchorX = 100.0;
      if (dx < anchorX) {
        dx = anchorX;
      } else if (dx > screenWidth - anchorX - _centerSeplineWidth) {
        dx = screenWidth - anchorX - _centerSeplineWidth;
      }
      _splitPosition = dx / screenWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final confModel = Provider.of<ConfigurationsModel>(context);
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
                    padding: EdgeInsets.fromLTRB(15, 1, 1, 1),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: double.infinity,
                        minWidth: double.infinity,
                      ),
                      child: TextField(
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "请在此处输入json文本",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        controller: textEditingController,
                        onChanged: (value) {
                          _confModel.resetpastedJsonString();
                          _handleConfChange();
                        },
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
                    padding: EdgeInsets.fromLTRB(15, 1, 1, 1),
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
                          hintStyle: TextStyle(color: Colors.grey),
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
