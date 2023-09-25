import 'package:shosai/utils/debug.dart';

/// 此日志一直输出。
void printD([String? tag, Object? msg]) {
  MyLog.d(tag, msg);
}

/// 目录匹配相关日志
void matchTocLog([String? tag, String? message]) {
  MyLog.d(tag, message);
}

/// 章节信息加载相关日志
void loadChapterLog([String? tag, String? message]) {
  // MyLog.d(tag, message);
}

/// 书源相关日志
void bookSourceLog(String? message) {
  // MyLog.d("bookSource", message);
}

/// 章节匹配相关日志
void matchChaptersLog([String? tag, String? message]) {
  // MyLog.d(tag, message);
}

/// 测量文本相关日志
void measureTextLog([String? tag, String? message]) {
  // MyLog.d(tag, message);
}

class MyLog {
  /// 此日志一直输出。
  static void i([String? tag, Object? msg]) {
    _v(tag, msg);
  }

  /// 此日志仅在debug时输出。
  static void d([String? tag, Object? msg]) {
    assert(() {
      _v(tag, msg);
      return true;
    }());
  }

  /// 此日志一直输出。
  static void e([String? tag, Object? msg]) {
    _v(tag, msg);
  }

  static void _v(String? tag, Object? msg) {
    if (tag == null) {
      print("$msg");
    } else if (msg == null) {
      print("$tag");
    } else {
      print("$tag: $msg");
    }
  }
}
