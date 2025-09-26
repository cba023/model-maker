import 'package:flutter/material.dart';
import 'package:model_maker/configurations_model.dart';
import 'package:model_maker/functions_app_bar.dart';
import 'package:model_maker/json_tool.dart';
import 'package:model_maker/debouncer.dart';
import 'package:model_maker/code_text_field_wrapper.dart';
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade50, // 浅灰色背景
        body: _buildHome(context),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.cyan.shade50,
            Colors.blue.shade50,
          ],
        ),
      ),
      child: Column(
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
      ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧：Logo信息
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.code,
                size:
                    isSmallMobile
                        ? 16
                        : isMobile
                        ? 18
                        : 20,
                color: Colors.blue.shade700,
              ),
              SizedBox(width: isSmallMobile ? 4 : 6),
              Text(
                'Model Maker',
                style: TextStyle(
                  fontSize:
                      isSmallMobile
                          ? 14
                          : isMobile
                          ? 16
                          : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: isSmallMobile ? 3 : 4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallMobile ? 4 : 6,
                  vertical: isSmallMobile ? 1 : 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(isSmallMobile ? 6 : 8),
                ),
                child: Text(
                  isSmallMobile ? 'Swift' : 'Swift模型生成器',
                  style: TextStyle(
                    fontSize:
                        isSmallMobile
                            ? 9
                            : isMobile
                            ? 11
                            : 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // 右侧：GitHub链接
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '本项目已开源',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _launchGitHubUrl(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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

  final double _centerSeplineWidth = 4;
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
        anchorX = 60.0; // 小手机端最小宽度
      } else if (isMobile) {
        anchorX = 80.0; // 手机端最小宽度
      } else if (isTablet) {
        anchorX = 100.0; // 平板端中等宽度
      } else {
        anchorX = 120.0; // 桌面端标准宽度
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
        return Container(
          padding: EdgeInsets.all(8), // 四周统一缩进
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onPanUpdate: (details) {
                  _updateSplitPosition(details.localPosition);
                },
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width:
                          (constraints.maxWidth - 16) *
                          _splitPosition, // 减去padding
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: double.infinity,
                              minWidth: double.infinity,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex:
                                      _showBottomTextField
                                          ? 1
                                          : 2, // 显示时占1份，隐藏时占2份
                                  child: CodeTextFieldWrapper(
                                    controller: textEditingController,
                                    hintText: "请在此处输入json文本或接口文档",
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
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    color: Colors.grey.shade300,
                                  ),
                                if (_showBottomTextField)
                                  Expanded(
                                    flex: 1, // 显示时占1份
                                    child: CodeTextFieldWrapper(
                                      controller:
                                          bottomLeftTextEditingController,
                                      hintText: "请在此处输入接口文档中的模型信息",
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
                      left: (constraints.maxWidth - 16) * _splitPosition,
                      top: 0,
                      bottom: 0,
                      width: 2, // 直接设置分隔条宽度为2px
                      // 分隔条宽度
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Icon(
                              Icons.drag_handle,
                              size: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left:
                          (constraints.maxWidth - 16) * _splitPosition +
                          2, // 使用固定的分隔条宽度
                      top: 0,
                      bottom: 0,
                      width:
                          (constraints.maxWidth - 16) * (1 - _splitPosition) -
                          2, // 使用固定的分隔条宽度
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: double.infinity,
                              minWidth: double.infinity,
                            ),
                            child: CodeTextFieldWrapper(
                              controller: textResultController,
                              hintText: "模型类生成后显示在此处",
                              readOnly: true,
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
      },
    );
  }
}
