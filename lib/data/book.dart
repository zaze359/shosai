import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shosai/main.dart';
import 'package:shosai/utils/display_util.dart';

/// Description : 书籍
/// @author zaze
/// @date 2022/6/5 - 13:03
class Book {
  Book(
      {required this.id,
      required this.name,
      required this.extension,
      required this.localPath});

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
  String toString() {
    return 'Book{id: $id, name: $name, localPath: $localPath, extension: $extension, charset: $charset}';
  }
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

class BookConfig {
  BookConfig(this.viewWidth, this.viewHeight);

  /// view的宽度(单位相当于android的dp)
  double viewWidth;
  /// view的高度(单位相当于android的dp)
  double viewHeight;
  int paddingTop = 0;
  int paddingBottom = 0;
  int paddingLeft = 0;
  int paddingRight = 0;

  double get pageWidth {
    return (viewWidth - paddingLeft - paddingRight);
  }

  double get pageHeight {
    return (viewHeight - paddingTop - paddingBottom);
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
    locale: Localizations.localeOf(navKey.currentState!.context),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  );

  TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    backgroundColor: Colors.red,
  );
  TextStyle textStyle = const TextStyle(
    fontSize: 20,
    backgroundColor: Colors.blue,
  );

  @override
  String toString() {
    return 'BookConfig{viewWidth: $viewWidth, viewHeight: $viewHeight, paddingTop: $paddingTop, paddingBottom: $paddingBottom, paddingLeft: $paddingLeft, paddingRight: $paddingRight}';
  }
}
