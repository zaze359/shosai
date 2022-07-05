/// 此日志一直输出。
void printD([String? tag, Object? msg]) {
  MyLog.d(tag, msg);
}

void bookSourceLog(String? message) {
  MyLog.d("bookSource", message);
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
