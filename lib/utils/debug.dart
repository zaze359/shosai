/// 目录匹配相关日志
bool matchTocLog = false;

/// 章节匹配相关日志
bool matchChaptersLog = false;

/// 章节加载相关日志
bool loadChapterLog = false;

/// 测量文本相关日志
bool measureTextLog = false;

void debug() {
  // debugPrintMarkNeedsLayoutStacks = true; // 重新布局时输出日志
  // debugPrintMarkNeedsPaintStacks = true; // 重新绘制时输出日志
  // debugPrintStack(); // 打印堆栈
  // debugPaintSizeEnabled = true; // 显示组件的布局边界
  // debugPaintBaselinesEnabled = true; // 显示组件的基准线
  // debugPaintPointersEnabled = true; // 任何正在点击的对象都会被深青色覆盖强调。
  // debugPaintLayerBordersEnabled = true; // 用橙色或轮廓线标出每个层的边界
  // debugRepaintRainbowEnabled = true; // 重绘时，会使该层被某个颜色所覆盖，颜色随机变化
  //
  // FlutterError.onError = (detail) {
  //   print("FlutterError: crash");
  // };
}

void dump() {
  // debugDumpApp();
  // debugPrintBeginFrameBanner = true;
  // debugPrintEndFrameBanner = true;
  // debugPrintScheduleFrameStacks = true;
  // debugDumpRenderTree();
  // debugDumpLayerTree();
}
