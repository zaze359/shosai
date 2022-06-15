class MyLog {

  /// 此日志一直输出。
  static void i(String? tag, Object? msg) {
    print("$tag: $msg");
  }

  /// 此日志仅在debug时输出。
  static void d(String? tag, Object msg) {
    assert(() {
      print("$tag: $msg");
      return true;
    }());
  }

  /// 此日志一直输出。
  static void e(String? tag, Object? msg) {
    print("$tag: $msg");
  }
}
