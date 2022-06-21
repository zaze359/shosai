import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shosai/main.dart';
import 'package:shosai/utils/display_util.dart' as display;

/// Description : 书籍
/// @author zaze
/// @date 2022/6/5 - 13:03
class Book {
  Book({
    required this.id,
    required this.name,
    required this.extension,
    required this.localPath,
  });

  /// 数据库id, file Uri
  String id;

  /// 书名
  String name;

  /// 书籍的本地存储路径。
  String localPath;

  /// 文件后缀
  String extension;

  /// 编码格式
  String? charset;

  /// 最近访问时间
  int latestVisitTime = 0;

  Book.empty()
      : id = "",
        name = "empty",
        extension = ".txt",
        localPath = "";

  Book.formFile(File file)
      : id = file.uri.toString(),
        name = path.basenameWithoutExtension(file.path),
        extension = path.extension(file.path),
        localPath = file.path;

  @override
  String toString() => '''
  书籍信息:
  -------------------
  id: $id
  书名: $name
  本地存储地址: $localPath
  文件后缀: $extension
  字符编码: $charset
  -------------------
  ''';
}

/// 书的章节
class BookChapter {
  BookChapter(
      {required this.bookId,
      required this.index,
      required this.title,
      this.charStart = 0,
      this.charEnd = 0});

  /// Book id
  String bookId;

  /// 章节位置
  int index;

  /// 章节标题
  String title;

  /// 章节从文本的第几个字节开始
  int charStart;

  /// 章节从文本的到第几个字节结束
  int charEnd;

  void reset(
      {required int index, required String title, required int charStart}) {
    this.title = title;
    this.index = index;
    this.charStart = charStart;
    charEnd = charStart;
  }

  BookChapter fork() {
    return BookChapter(
      bookId: bookId,
      index: index,
      title: title,
      charStart: charStart,
      charEnd: charEnd,
    );
  }

  @override
  String toString() {
    return 'BookChapter{bookId: $bookId, index: $index, title: $title, charStart: $charStart, charEnd: $charEnd}';
  }
}

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
  TextPainter textPainter = TextPainter(
    // locale: Localizations.localeOf(navKey.currentState!.context),
    textScaleFactor: display.textScaleFactor,
    maxLines: 1,
    textDirection: TextDirection.ltr,
  );

  /// 标题样式
  TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
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
