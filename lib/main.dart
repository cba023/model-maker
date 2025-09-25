import 'package:flutter/material.dart';
import 'package:model_maker/configurations_model.dart';
import 'package:model_maker/functions_app_bar.dart';
import 'package:model_maker/json_tool.dart';
import 'package:model_maker/debouncer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ConfigurationsModel(),
      child: MaterialApp(home: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: _buildHome(context)));
  }

  Widget _buildHome(BuildContext context) {
    return Column(
      children: [
        FunctionsAppBar(),
        Expanded(
          child: Container(
            width: double.infinity,
            child: SplitWindow(key: key),
          ),
        ),
        _buildGitHubFooter(context),
      ],
    );
  }

  Widget _buildGitHubFooter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 480;
    final isMobile = screenWidth >= 480 && screenWidth < 768;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical:
            isSmallMobile
                ? 12
                : isMobile
                ? 14
                : 16,
        horizontal:
            isSmallMobile
                ? 12
                : isMobile
                ? 16
                : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade50, Colors.grey.shade100],
        ),
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '该项目已开源',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _launchGitHubUrl(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GitHub',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGitHubUrl() async {
    try {
      final Uri url = Uri.parse('https://github.com/cba023/model-maker');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // 如果无法打开链接，显示一个提示
      print('无法打开链接: $e');
      // 可以在这里添加一个SnackBar或其他用户提示
    }
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
  var bottomLeftTextEditingController = TextEditingController();
  var textResultController = TextEditingController();
  late ConfigurationsModel _confModel;
  // 控制下面TextField是否显示的变量
  bool _showBottomTextField = false;
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
      setState(() {
        _showBottomTextField = _confModel.isMate;
      });
      JsonTool.asyncGenerateModels(
            textEditingController.text,
            bottomLeftTextEditingController.text,
            _confModel,
          )
          .then((data) {
            setState(() {
              textResultController.text = data ?? '';
              outputResult = textResultController.text;
            });
          }) // 成功回调
          .catchError((error) {
            print('错误: $error');
            return null;
          }) // 错误回调
          .whenComplete(() => print('操作完成')); // 最终回调
    });
  }

  // 根据屏幕宽度获取合适的内边距
  double _getPaddingForScreen(double screenWidth) {
    if (screenWidth < 480) {
      return 8.0; // 小手机端
    } else if (screenWidth < 768) {
      return 10.0; // 手机端
    } else if (screenWidth < 1200) {
      return 12.0; // 平板端
    } else {
      return 16.0; // 桌面端
    }
  }

  void _updateSplitPosition(Offset position) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 使用与AppBar相同的断点系统
    final bool isSmallMobile = screenWidth < 480;
    final bool isMobile = screenWidth >= 480 && screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;

    setState(() {
      double dx = position.dx;
      double anchorX;

      if (isSmallMobile) {
        anchorX = 40.0; // 小手机端最小宽度
      } else if (isMobile) {
        anchorX = 50.0; // 手机端最小宽度
      } else if (isTablet) {
        anchorX = 80.0; // 平板端中等宽度
      } else {
        anchorX = 100.0; // 桌面端标准宽度
      }

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
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      _getPaddingForScreen(MediaQuery.of(context).size.width),
                      8,
                      8,
                      8,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: double.infinity,
                        minWidth: double.infinity,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: _showBottomTextField ? 1 : 2, // 显示时占1份，隐藏时占2份
                            child: TextField(
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: "请在此处输入json文本或接口文档",
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

                          // 下面的TextField，根据变量控制是否显示
                          if (_showBottomTextField)
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.grey.shade300,
                            ),
                          if (_showBottomTextField)
                            Expanded(
                              flex: 1, // 显示时占1份
                              child: TextField(
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: "请在此处输入接口文档中的模型信息",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                                controller: bottomLeftTextEditingController,
                                onChanged: (value) {
                                  _handleConfChange();
                                },
                              ),
                            ),
                        ],
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
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300, width: 1),
                      right: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Icon(
                        Icons.drag_handle,
                        size: _centerSeplineWidth * 0.6,
                        color: Colors.grey.shade600,
                      ),
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
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      _getPaddingForScreen(MediaQuery.of(context).size.width),
                      8,
                      8,
                      8,
                    ),
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
