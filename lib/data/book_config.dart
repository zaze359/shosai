
import 'package:flutter/material.dart';
import 'package:shosai/utils/display_util.dart' as display;

/// 定义一个全局变量。
BookConfig bookConfig = BookConfig();

/// 书籍配置
class BookConfig {
  BookConfig._internal(this.viewWidth, this.viewHeight);

  static final BookConfig _instance = BookConfig._internal(0, 0);

  factory BookConfig([double viewWidth = 0, double viewHeight = 0]) {
    _instance.updateSize(viewWidth, viewHeight);
    return _instance;
  }

  /// view的宽度(单位相当于android的dp)
  double viewWidth = 0.0;

  /// view的高度(单位相当于android的dp)
  double viewHeight = 0.0;

  /// 内填充边距
  double paddingTop = 8.0;
  double paddingBottom = 8.0;
  double paddingLeft = 8.0;
  double paddingRight = 8.0;

  double aspectRatio = 1.0;

  double get pageWidth {
    return (viewWidth - paddingLeft - paddingRight);
  }

  double get pageHeight {
    return (viewHeight - paddingTop - paddingBottom);
  }

  void updateSize(double viewWidth, double viewHeight) {
    this.viewWidth = viewWidth;
    this.viewHeight = viewHeight;
    aspectRatio = viewWidth / viewHeight;
  }

  // double get pageWidthPixel {
  //   return pageWidth * Display.devicePixelRatio;
  // }
  //
  // double get pageHeightPixel {
  //   return pageHeight * Display.devicePixelRatio;
  // }

  /// 创建文本绘制器，用于测量文本
  TextPainter get textPainter => TextPainter(
    // locale: Localizations.localeOf(navKey.currentState!.context),
    textScaleFactor: display.textScaleFactor,
    maxLines: 1,
    textDirection: TextDirection.ltr,
  );

  /// 标题样式
  TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 2,
    // backgroundColor: Colors.red,
  );

  /// 文本内容样式
  TextStyle textStyle = const TextStyle(
    fontSize: 20,
    // backgroundColor: Colors.blue,
  );

  @override
  String toString() => '''
  书籍配置:
  -------------------
  视图大小: $viewWidth/$viewHeight($aspectRatio)
  视图padding: ($paddingLeft,$paddingTop,$paddingRight,$paddingBottom)
  -------------------
  ''';
}
