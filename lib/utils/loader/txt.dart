import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_state.dart';
import 'package:shosai/utils/charsets.dart';
import 'package:shosai/utils/loader/loader.dart';
import 'package:shosai/utils/log.dart';

class TxtLoader extends ChapterLoader {
  /// 1. 空白符开头
  /// 2. 第
  /// 3. \s\d〇零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟 可重复多次，但是尽可能少
  /// 4. 章部节卷集级片篇回
  /// 5. 后面什么都没 或者 存在至少一个空格、下划线、-等特殊符号
  /// 6. 至多20个字的章节描述
  /// 7. 以{1, 2}个空白符结尾
  final RegExp _chapterPattern = RegExp(
      r'^\s*?第[\s\d〇零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]+?[章部节卷集片篇回]([ -_]+(.{0,20})?)?\s?$');

  /// 换行符 \n
  final int _blank = 0x0a;

  TxtLoader(super.book, super.config);

  late CharsetDecoder decoder = CharsetDecoder(book.charset);

  /// 返回匹配结果，若不匹配则返回null
  @override
  String? matchTitle(String line) {
    Iterable<Match> matchers = _chapterPattern.allMatches(line);
    // MyLog.d("TxtLoader", "-------------------------------");
    // MyLog.d("TxtLoader", "matchTitle line: ${matchers.length} >> $line");
    for (var match in matchers) {
      String? matched = match.group(0)?.trim().replaceAll("\n", "");
      // MyLog.d("TxtLoader", "matchTitle line matched : $line");
      // MyLog.d("TxtLoader", "matched Title : $matched");
      return matched;
    }
    return null;
  }

  @override
  Future<List<BookChapter>> matchChapters() async {
    int chapterIndex = 0;
    List<BookChapter> chapters = [];
    Stream<List<int>>? contentStream = _readFileContent(book.localPath);
    if (contentStream == null) {
      return [];
    }
    // 首先创建第一个章节
    BookChapter bookChapter =
        BookChapter(bookId: book.id, index: chapterIndex, title: "开始");
    int blankIndex = 0;
    List<int> decodeList = [];
    // 已处理到字节数
    int offset = 0;
    await for (List<int> element in contentStream) {
      blankIndex = 0;
      for (var i = 0; i < element.length - 1; i++) {
        if (element[i] == _blank) {
          // 匹配到换行字符，将两个换行符直接到位置添加到 检测队列中。
          decodeList.addAll(element.sublist(blankIndex, i));
          String? title = matchTitle(decoder.decode(decodeList));
          if (title != null) {
            // 章节结束的位置 = 之前章节的结束位置 + 当的换行位置。
            bookChapter.charEnd = offset + blankIndex;
            // MyLog.d("loadChapters",
            //     "message: blankIndex:$blankIndex;  i: $i; decodeList:${decodeList.length}");
            // MyLog.d("loadChapters", "add bookChapter $bookChapter");
            chapters.add(bookChapter.fork());
            bookChapter.reset(
              index: ++chapterIndex,
              title: title,
              charStart: bookChapter.charEnd,
            );
          }
          decodeList.clear();
          // 记录换行位置
          blankIndex = i;
        }
      }
      offset += element.length;
      // 将剩余部分添加到解码队列中
      decodeList.addAll(element.sublist(blankIndex, element.length - 1));
    }
    bookChapter.charEnd = offset;
    if (bookChapter.charStart != bookChapter.charEnd) {
      chapters.add(bookChapter.fork());
    }
    // 修改一下书本的字符
    book.charset ??= decoder.charset;
    return chapters;
  }

  Stream<List<int>>? _readFileContent(String? localPath,
      {int? start, int? end}) {
    try {
      if (localPath == null || localPath.isEmpty) {
        return null;
      }
      File file = File(localPath);
      if (!file.existsSync()) {
        return null;
      }
      return file.openRead(start, end);
      // Stream<List<int>> inputStream = file.openRead(start, end);
      // book.charset ??= decoder.charset;
      // return decoder.bind(inputStream).transform(const LineSplitter());
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ChapterState> loadChapterContent(BookChapter chapter) async {
    MyLog.d("loadChapterContent", "chapter: $chapter");
    Stream<List<int>>? stream = _readFileContent(book.localPath,
        start: chapter.charStart, end: chapter.charEnd);
    ChapterState chapterState = ChapterState(chapter);
    if (stream == null) {
      return ChapterState(chapter);
    }
    //
    // double maxWidth = config.pageWidthPixel;
    // double maxHeight = config.pageHeightPixel;
    //
    List<TextSpan> lines = [];
    await for (String line
        in decoder.bind(stream).transform(const LineSplitter())) {
      // for (var element in line.characters) {
      //   // 测量文字
      // }
      measure(config.textPainter, line, config.pageWidthPixel);
      lines.add(TextSpan(text: "$line\n"));
    }
    PageState pageState = PageState(lines);
    chapterState.pages = [pageState];
    return chapterState;
  }

  /// 测量文本宽高
  void measure(TextPainter textPainter, String text, double maxWidth) {
    textPainter.text = TextSpan(text: text, style: config.textStyle);
    textPainter.layout(maxWidth: maxWidth);
    // MyLog.d("loadChapterContent",
    //     "_textPainter: ${textPainter.width}/${textPainter.height}/${textPainter.didExceedMaxLines} >> $text");
  }
}
