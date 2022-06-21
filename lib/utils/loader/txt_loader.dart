import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_state.dart';
import 'package:shosai/utils/charsets.dart';
import 'package:shosai/utils/debug.dart' as debug;
import 'package:shosai/utils/file_util.dart';
import 'package:shosai/utils/loader/loader.dart';
import 'package:shosai/utils/log.dart';

import '../display_util.dart';

class TxtLoader extends ChapterLoader {
  /// \u200b unicode零宽度字符,不可见字符
  final List<String> ignoreChars = ['\u200b'];

  TxtLoader(super.book, super.config);

  @override
  Future<List<BookChapter>> matchChapters(RegExp regExp) async {
    Stream<List<int>> contentStream = FileService.openRead(book.localPath);
    List<int> codeList = [];
    // 加载完再处理，保证内容完整。
    if (debug.matchChaptersLog) {
      MyLog.d("TxtLoader", "matchChapters read content start");
    }
    await for (List<int> element in contentStream) {
      codeList.addAll(element);
    }
    if (debug.matchChaptersLog) {
      MyLog.d("TxtLoader", "matchChapters read content end");
    }
    if (codeList.isEmpty) {
      return [];
    }
    // 计算密集型，放isolate中处理。
    MapEntry<String?, List<BookChapter>> result =
        await compute(_codesMapToBookChapters, MapEntry(codeList, regExp));
    // codesMapToBookChapters(MapEntry(codeList, regExp));
    // 修改一下书本的字符
    book.charset = result.key;
    return result.value.map((e) {
      e.bookId = book.id;
      return e;
    }).toList();
  }

  @override
  Future<ChapterState> loadChapterContent(BookChapter chapter) async {
    // MyLog.d("loadChapterContent", "_readFileContent start: $chapter");
    Stream<List<int>> stream = FileService.openRead(book.localPath,
        start: chapter.charStart, end: chapter.charEnd);
    // MyLog.d("loadChapterContent", "_readFileContent end: $chapter");
    ChapterState chapterState = ChapterState(chapter);
    List<PageLine> pageLines = [];
    TextPainter textPainter = config.textPainter;
    TextStyle style;
    double maxWidth = config.pageWidth;
    CharsetDecoder decoder = CharsetDecoder(book.charset);
    if (debug.loadChapterLog) {
      MyLog.d("TxtLoader",
          "loadChapterContent: ${decoder.charset} (${chapter.charStart}/${chapter.charEnd})");
    }
    List<String> contentLines =
        await (decoder.bind(stream).transform(const LineSplitter()).toList());
    if (debug.loadChapterLog) {
      MyLog.d("TxtLoader",
          "loadChapterContent contentLines.length ${contentLines.length}");
    }
    FrameCross frameCross = FrameCross();
    for (String line in contentLines) {
      // --------------------------------------------
      if (pageLines.isEmpty) {
        // 第一行。是标题
        style = config.titleStyle;
      } else {
        style = config.textStyle;
      }
      // --------------------------------------------------
      line = line.trim();
      if (line.isEmpty) {
        continue;
      }
      if (line.length == 1) {
        // 可能是一些非法字符
        if (ignoreChars.contains(line)) {
          continue;
        }
        CharsetEncoder encoder = CharsetEncoder(book.charset);
        MyLog.d(
            "TxtLoader",
            "loadChapterContent: ${line.codeUnits}/${encoder.encode(line).map((e) {
              return e.toRadixString(16);
            })}/${encoder.charset}");
        measure(textPainter, line, style, maxWidth);
        if (textPainter.width == 0) {
          continue;
        }
      }
      // 格式化line
      line = formatLine(line);
      int edgeIndex = 0;
      int startIndex = edgeIndex;
      String splitLine = line;
      if (debug.loadChapterLog) {
        MyLog.d("TxtLoader",
            "loadChapterContent splitLine.length：${splitLine.length}");
      }
      // TODO 需要处理一行但是，这一行长度很大的情况。
      while (edgeIndex < line.length) {
        edgeIndex = edgeIndex +
            await findLineEdge(
                textPainter: textPainter,
                line: splitLine,
                maxWidth: maxWidth,
                style: style,
                frameCross: frameCross);
        // TODO 需要处理分割后的空白部分
        pageLines.add(PageLine(line.substring(startIndex, edgeIndex),
            style: style, height: textPainter.height));
        if (edgeIndex == line.length) {
          break;
        }
        // 处理剩余部分数据
        startIndex = edgeIndex;
        splitLine = line.substring(edgeIndex, line.length);
      }
      await frameCross.doDelay();
    }
    // MyLog.d("loadChapterContent", "------- lines: ${lines.length}");
    // 分页
    double maxHeight = config.pageHeight;
    double curHeight = 0;
    PageState pageState = PageState();
    for (PageLine line in pageLines) {
      curHeight += line.height;
      if (curHeight >= maxHeight) {
        chapterState.addPage(pageState);
        MyLog.i(
            "line space: $chapterState >> ${maxHeight - curHeight + line.height}");
        pageState = PageState();
        curHeight = line.height;
      }
      MyLog.d("loadChapterContent", "line: ${line.text}");
      pageState.lines.add(line);
    }
    if (pageState.isNotEmpty) {
      chapterState.addPage(pageState);
    }
    return chapterState;
  }

  /// 格式化一行
  String formatLine(String line) {
    line = line.trim();
    if (line.isNotEmpty) {
      if (line.length == 1) {
        MyLog.d("TxtLoader",
            "formatLine length == 1 : $line/${line.codeUnitAt(0)}/${"\r\n".codeUnits}");
      }
      return "    $line";
    } else {
      return "";
    }
  }

  /// 根据最大宽度找到一行的边界字符位置
  Future<int> findLineEdge(
      {required TextPainter textPainter,
      required String line,
      required double maxWidth,
      required TextStyle style,
      required FrameCross frameCross}) async {
    int edgeIndex = line.length;
    int maxLength = 2 * maxWidth ~/ (style.fontSize ?? 1 * textScaleFactor);
    if (line.length > maxLength) {
      // 文字过多， 直接截断
      line = line.substring(0, maxLength);
      edgeIndex = maxLength;
    }
    measure(textPainter, line, style, maxWidth);
    // MyLog.d(
    //     "findLineEdge: maxWidth:$maxWidth; style.fontSize:${style.fontSize}; maxLength: $maxLength; edgeIndex: $edgeIndex; line: $line;");
    if (textPainter.didExceedMaxLines) {
      // 大致定位文本边界：实际文本宽度/最大宽度
      edgeIndex = line.length * maxWidth ~/ textPainter.minIntrinsicWidth;
      // MyLog.d("loadChapterContent", "----------------------------------------");
      if (!textPainter.didExceedMaxLines) {
        // 没有超出宽度, 并且未到边界， 则尝试往后增加字符
        while (!textPainter.didExceedMaxLines && edgeIndex < line.length) {
          await frameCross.doDelay();
          edgeIndex++;
          measure(textPainter, line.substring(0, edgeIndex), style, maxWidth);
        }
        // 最后若到边界则回退一个位置
        if (textPainter.didExceedMaxLines) {
          edgeIndex--;
        }
      } else {
        // 若超出宽度，往回减字符，直到不再超出，找到最近的边界。
        while (textPainter.didExceedMaxLines) {
          await frameCross.doDelay();
          edgeIndex--;
          measure(textPainter, line.substring(0, edgeIndex), style, maxWidth);
        }
      }
    }
    return edgeIndex;
  }

  /// 测量文本宽高
  void measure(
      TextPainter textPainter, String line, TextStyle style, double maxWidth) {
    textPainter.text = TextSpan(text: line, style: style);
    textPainter.layout(maxWidth: maxWidth);
    if (debug.measureTextLog) {
      MyLog.d("TxtLoader",
          "measure: (${textPainter.width}x${textPainter.height})； ${textPainter.minIntrinsicWidth}/${textPainter.maxIntrinsicWidth}； ${textPainter.didExceedMaxLines} >> $line");
    }
  }
}

class FrameCross {
  int computeTime = 0;
  int latestTime = DateTime.now().millisecondsSinceEpoch;

  /// TODO 这个机制生效了，并且运行的很好，后续再思考如何优化。暂时记录一下为什么这么写，方便以后理解。
  /// why:
  ///   loadChapterContent 频繁调用了textPainter.layout 测量章节文本内容然后进行分行分页, 导致页面卡顿， 测试发现主要在测量。
  /// 也考虑过使用compute(isolates)来优化, 但是实际这么做来之后发现TextPainter.layout会报错。
  /// 报错: UI actions are only available on root isolate。。。；主要是因为内部的ui.ParagraphBuilder。
  ///
  /// 不知如何处理，所以决定通过向事件队列添加一个Future.delay() event，并等待，让已在队列中的其他事件队列能够被执行。
  /// 为了尽量模拟 60帧，在处理事件接近16ms, 添加delay event。
  doDelay() async {
    // --------------------------------------------
    int offsetTime = DateTime.now().millisecondsSinceEpoch - latestTime;
    computeTime += offsetTime;
    latestTime += offsetTime;
    if (computeTime > 15) {
      // if (debug.loadChapterLog) {
      //   MyLog.d("TxtLoader",
      //       "FrameCross computeTime: $computeTime; offsetTime:$offsetTime;");
      // }
      computeTime = 0;
      await Future.delayed(const Duration(milliseconds: 1));
    }
  }
}

/// return MapEntry<String, List<BookChapter>>
/// key: charset;  value: List<BookChapter>
MapEntry<String?, List<BookChapter>> _codesMapToBookChapters(
    MapEntry<List<int>, RegExp> data) {
  List<int> codeList = data.key;
  RegExp regExp = data.value;
  CharsetDecoder decoder = CharsetDecoder();
  decoder.initCharset(codeList);
  int blankCharOffset = _blankCharOffset(decoder.charset);
  if (debug.matchChaptersLog) {
    MyLog.d("TxtLoader",
        "codesMapToBookChapters RegExp: $regExp; codeList: ${codeList.length}; blankCharOffset: $blankCharOffset;");
  }
  // MyLog.d(
  //     "TxtLoader",
  //     "matchTitle line(${element.length}) (${element.sublist(0, element.length).fold("", (String previousValue, int element) {
  //       return "${previousValue} 0x${element.toRadixString(16)}";
  //     })})");
  // MyLog.d(
  //     "TxtLoader",
  //     "matchTitle line (${element.sublist(6, 26).fold("", (String previousValue, int element) {
  //       return "${previousValue} 0x${element.toRadixString(16)}";
  //     })})");

  int chapterIndex = 0;
  int blankEndIndex = 0;
  int lineStart = 0;
  List<int> decodeList = [];
  // 首先创建第一个章节
  BookChapter bookChapter =
      BookChapter(bookId: "", index: chapterIndex, title: "开始");
  List<BookChapter> chapters = [];
  for (var i = 0; i < codeList.length; i++) {
    if (_matchBlank(decoder.charset, codeList, i)) {
      // 匹配到换行符, 根据对应编码判断当前code是否是完整字符的真正结束位置。
      blankEndIndex = i + blankCharOffset;
      // 截取这一行数据，放入到检测队列中。此时内部可能是 上次未处理完的数据 加上这次的新数据
      decodeList.addAll(codeList.sublist(lineStart, blankEndIndex + 1));
      // 匹配是否是标题
      String? title = matchToc(regExp, decoder.decode(decodeList));
      if (title != null && debug.matchChaptersLog) {
        MyLog.d("TxtLoader",
            "codesMapToBookChapters 1 index: $i  ($lineStart - $blankEndIndex); ");
        MyLog.d(
            "TxtLoader",
            "codesMapToBookChapters 2 $title (${codeList.sublist(lineStart, blankEndIndex + 1).fold("", (String previousValue, int element) {
              return "$previousValue 0x${element.toRadixString(16)}";
            })})");
      }
      if (title != null) {
        // 章节结束的位置。
        bookChapter.charEnd = lineStart;
        if (debug.matchChaptersLog) {
          MyLog.d("TxtLoader",
              "codesMapToBookChapters 3 bookChapter: ${bookChapter.title} ${bookChapter.index}; charStart:${bookChapter.charStart}; charEnd:${bookChapter.charEnd}");
        }
        chapters.add(bookChapter.fork());
        // 重置并初始化新章节。
        bookChapter.reset(
          index: ++chapterIndex,
          title: title,
          charStart: bookChapter.charEnd,
        );
      }
      decodeList.clear();
      // 下一个位置作为新一行数据的开始位置
      lineStart = blankEndIndex + 1;
    }
  }
  // 将暂未匹配到换行符到剩余部分添加到解码队列中
  // 最后剩余部分直接归并到最后一个章节。
  bookChapter.charEnd = codeList.length;
  if (bookChapter.charStart != bookChapter.charEnd) {
    chapters.add(bookChapter.fork());
  }
  if (debug.matchChaptersLog) {
    MyLog.d("TxtLoader",
        "codesMapToBookChapters end charset: ${decoder.charset}; ${chapters.length}");
  }
  return MapEntry(decoder.charset, chapters);
}

/// 返回匹配结果，若不匹配则返回null
String? matchToc(RegExp regExp, String line) {
  Iterable<Match> matchers = regExp.allMatches(line);
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

/// 换行符 \n
const int _blank = 0x0a;

/// 判断是否是换行符。
bool _matchBlank(String? charset, List<int> element, int i) {
  switch (charset) {
    case CharsetCodec.utf8:
      // 1字节 FF
      // 0x0a
      return element[i] == _blank;
    case CharsetCodec.utf16le:
      // 2字节(FF FF)，小端
      // 0x0a  0x00
      return (element[i] == _blank &&
          i < (element.length - 1) &&
          element[i + 1] == 0x00);
    case CharsetCodec.utf16be:
      // 2字节(FF FF)，大端
      // 0x00  0x0a
      return (element[i] == _blank && i > 0 && element[i - 1] == 0x00);
    case CharsetCodec.utf32le:
      return element[i] == _blank;
    case CharsetCodec.utf32be:
      return element[i] == _blank;
    default:
      return element[i] == _blank;
  }
}

/// 返回完整空行符的偏移量
int _blankCharOffset(String? charset) {
  switch (charset) {
    case CharsetCodec.utf8:
      // 1字节 FF
      // 0x0a
      return 0;
    case CharsetCodec.utf16le:
      // 2字节(FF FF)，小端
      // 0x0a  0x00
      return 1;
    case CharsetCodec.utf16be:
      // 2字节(FF FF)，大端
      // 0x00  0x0a
      return 0;
    case CharsetCodec.utf32le:
    case CharsetCodec.utf32be:
    default:
      return 0;
  }
}
