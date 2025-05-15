import 'dart:async';
import 'dart:ui';

/// 限流工具类
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer(Duration duration, {this.milliseconds = 300});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel(); // 取消前一个计时器
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
