import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:model_maker/configurations_model.dart';
import 'package:model_maker/functions_app_bar.dart';
import 'package:model_maker/json_tool.dart';
import 'package:model_maker/debouncer.dart';
import 'package:model_maker/code_text_field_wrapper.dart';
import 'package:model_maker/json_formatter.dart';
import 'package:model_maker/string_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configModel = ConfigurationsModel();
  await configModel.loadAllConfigurations();
  runApp(
    ChangeNotifierProvider(
      create: (context) => configModel,
      child: MaterialApp(home: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// 获取平台特定的文本
  String _getPlatformSpecificText() {
    // 检查是否为Web平台
    if (kIsWeb) {
      // Web平台显示Mac版信息
      return '已开源，并提供Mac版';
    } else {
      // Mac/桌面平台显示网页版信息
      return '已开源，并提供网页版';
    }
  }

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
              SizedBox(width: isSmallMobile ? 3 : 4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallMobile ? 4 : 6,
                  vertical: isSmallMobile ? 1 : 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(isSmallMobile ? 6 : 8),
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child: Text(
                  'v1.2.12',
                  style: TextStyle(
                    fontSize:
                        isSmallMobile
                            ? 8
                            : isMobile
                            ? 10
                            : 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: isSmallMobile ? 6 : 8),
              Tooltip(
                message: '使用说明',
                child: GestureDetector(
                  onTap: () => _showUsageDialog(context),
                  child: Icon(
                    Icons.help_outline,
                    size: isSmallMobile ? 18 : 20,
                    color: Colors.grey.shade400,
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
                    _getPlatformSpecificText(),
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
      print('无法打开链接: $e');
    }
  }

  void _showUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 24,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '使用说明',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUsageItem(
                          '使用驼峰命名',
                          '生成的属性名使用驼峰命名法（camelCase），如 userName、firstName',
                        ),
                        _buildUsageItem(
                          '使用结构体',
                          '生成 Swift 结构体（struct）而不是类（class），结构体是值类型',
                        ),
                        _buildUsageItem(
                          '支持Objective-C',
                          '添加 @objc 和 @objcMembers 标记，使 Swift 代码可以被 Objective-C 调用',
                        ),
                        _buildUsageItem(
                          '支持SmartCodable',
                          '使用 SmartCodable 库进行 JSON 编解码，支持更多类型和自定义映射',
                        ),
                        _buildUsageItem(
                          '原生Codable',
                          '使用 Swift 原生的 Codable 协议进行 JSON 编解码',
                        ),
                        _buildUsageItem(
                          '(Smart)Codable映射',
                          '启用 JSONKey 映射，支持自定义字段名映射规则',
                        ),
                        _buildUsageItem(
                          '支持YYModel',
                          '生成 YYModel 兼容的代码，用于 iOS 开发中的 JSON 解析',
                        ),
                        _buildUsageItem(
                          '支持public',
                          '将生成的类和属性标记为 public，使其可以在模块外部访问',
                        ),
                        _buildUsageItem(
                          '生成构造方法',
                          '为模型生成初始化构造方法，方便创建实例',
                        ),
                        _buildUsageItem(
                          '反序列化静态方法',
                          '生成静态的反序列化方法（如 fromJSON()），方便在外部调用时直接解析 JSON 返回的数据生成数据模型',
                        ),
                        _buildUsageItem(
                          'Swagger接口文档',
                          '勾选:启用Swagger接口文档解析模式；未勾选:启用Knife4j增强版接口文档解析模式',
                        ),
                      ],
                    ),
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

  Widget _buildUsageItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
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

  final double _centerSeplineWidth = 4;
  var textEditingController = TextEditingController();
  var bottomLeftTextEditingController = TextEditingController();
  bool _showFormatButton = false; // 是否显示格式化按钮
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
    // 立即更新UI状态（特别是isMate相关的显示状态）
    setState(() {
      _showBottomTextField = _confModel.isMate;
    });

    // 使用防抖处理模型生成
    _debouncer.run(() {
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

  /// 格式化JSON
  void _formatJson() {
    final formattedJson = JsonFormatter.formatJson(textEditingController.text);
    setState(() {
      textEditingController.text = formattedJson;
    });
  }

  /// 清空内容
  void _clearContent() {
    textEditingController.clear();
    _handleConfChange();
    _updateFormatButtonVisibility();
  }

  /// 加载示例文档
  void _loadSampleDocument() {
    // 直接在代码中定义示例文档内容
    const sampleContent = '''## 用户信息接口

**接口地址** `/api/user/info`

**请求方式** `GET`

**consumes** `["application/json"]`

**produces** `["application/json"]`

**接口描述** 获取用户基本信息

**请求参数**

| 参数名称 | 参数说明 | 请求类型 | 是否必须 | 数据类型 | schema |
|---------|---------|---------|---------|---------|--------|
| userId  | 用户ID   | query   | true    | integer |        |

**响应状态**

| 状态码 | 说明 | schema |
|--------|------|--------|
| 200    | OK   | UserInfo |

**响应参数**

| 参数名称 | 参数说明 | 类型 | schema |
|---------|---------|------|--------|
| id      | 用户ID   | integer |        |
| name    | 用户名   | string  |        |
| email   | 邮箱地址 | string  |        |
| age     | 年龄     | integer |        |
| avatar  | 头像URL  | string  |        |
| is_active | 是否激活 | boolean |        |
| tags    | 标签列表 | array   | string  |
| profile | 用户资料 | object  | UserProfile |

**schema属性说明**

**UserProfile**

| 参数名称 | 参数说明 | 类型 | schema |
|---------|---------|------|--------|
| bio     | 个人简介 | string |        |
| location| 所在地   | string |        |
| website | 个人网站 | string |        |
| phone   | 电话号码 | string |        |

**响应示例**

```json
{
  "id": 12345,
  "name": "张三",
  "email": "zhangsan@example.com",
  "age": 25,
  "avatar": "https://example.com/avatar.jpg",
  "is_active": true,
  "tags": ["开发者", "设计师", "产品经理"],
  "profile": {
    "bio": "热爱编程的开发者",
    "location": "北京",
    "website": "https://zhangsan.dev",
    "phone": "13800138000"
  }
}
```''';

    // 将内容设置到第一个输入框
    textEditingController.text = sampleContent;

    // 触发配置变更，生成模型
    _handleConfChange();
  }

  /// 检查并更新格式化按钮显示状态
  void _updateFormatButtonVisibility() {
    final isValid = JsonFormatter.isValidJson(textEditingController.text);
    if (_showFormatButton != isValid) {
      setState(() {
        _showFormatButton = isValid;
      });
    }
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
                                    showFormatButton: _showFormatButton,
                                    onFormat: _formatJson,
                                    onLoadSample: _loadSampleDocument,
                                    onClear: _clearContent,
                                    onChanged: (value) {
                                      _confModel.resetpastedJsonString();
                                      _handleConfChange();
                                      _updateFormatButtonVisibility();
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
                                      showFloatingButtons: false, // 不显示悬浮按钮
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
                              showFloatingButtons: false, // 不显示悬浮按钮
                              showCopyButton: true, // 显示复制按钮
                              onCopy:
                                  () => _copyToClipboard(
                                    context,
                                    textResultController.text,
                                  ),
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
