import 'package:flutter/cupertino.dart';
import 'package:shosai/data/book.dart';

/// 书本的阅读状态
class BookReadingState {
  BookReadingState(this.book);

  Book? book;
  List<BookChapter> bookChapters = [];

  /// 当前章节位置
  int chapterIndex = 0;

  BookChapter? getCurChapter() {
    if (isOver()) {
      return null;
    }
    return bookChapters[chapterIndex];
  }

  BookChapter? getNextChapter() {
    if (isLast()) {
      return null;
    }
    return bookChapters[chapterIndex + 1];
  }

  BookChapter? getPrevChapter() {
    if (isFirst()) {
      return null;
    }
    return bookChapters[chapterIndex - 1];
  }

  /// 移动到下一章节
  bool moveUp() {
    if (isFirst()) {
      return false;
    } else {
      chapterIndex--;
      return true;
    }
  }

  /// 移动到下一章节
  bool moveDown() {
    if (isLast()) {
      return false;
    } else {
      chapterIndex++;
      return true;
    }
  }

  void moveTo(int index) {
    if (index < 0) {
      chapterIndex = 0;
    } else if (index >= bookChapters.length) {
      chapterIndex = bookChapters.length;
    } else {
      chapterIndex = index;
    }
  }

  bool isFirst() {
    return chapterIndex == 0;
  }

  /// 是否是最后一章
  bool isLast() {
    return chapterSize == 0 || chapterIndex == chapterSize - 1;
  }

  bool isOver() {
    return chapterIndex >= bookChapters.length;
  }

  /// 章节数量
  int get chapterSize {
    return bookChapters.length;
  }
}

/// 章节内容
class ChapterState {
  ChapterState([this.bookChapter]);

  BookChapter? bookChapter;
  List<PageState> _pages = [];

  set pages(List<PageState> value) {
    _pages = value;
  }

  void addPage(PageState pageState) {
    _pages.add(pageState);
  }

  int get chapterIndex => bookChapter?.index ?? 0;

  /// 当前章节的第几页
  int pageIndex = 0;

  PageState getCurPage() {
    if (isOver()) {
      return PageState();
    }
    return _pages[pageIndex];
  }

  /// 移动到上一页
  bool moveUp() {
    if (isFirst()) {
      return false;
    } else {
      pageIndex--;
      return true;
    }
  }

  ///移动到下一页
  bool moveDown() {
    if (isLast()) {
      return false;
    } else {
      pageIndex++;
      return true;
    }
  }

  bool isFirst() {
    return pageIndex == 0;
  }

  bool isLast() {
    return pageIndex == _pages.length - 1;
  }

  bool isOver() {
    return pageIndex >= _pages.length;
  }

  /// 到第一页
  void toFirstPage() {
    pageIndex = 0;
  }

  /// 到最后一页
  void toLastPage() {
    pageIndex = _pages.length - 1;
  }

  @override
  String toString() {
    return 'ChapterState: ${bookChapter?.title}(${_pages.length} - $pageIndex)';
  }
}

/// 阅读页
class PageState {
  PageState();

  List<PageLine> lines = [];

  bool get isNotEmpty => lines.isNotEmpty;

  @override
  String toString() {
    return 'PageState{lines: ${lines.isNotEmpty ? lines.first : ""}")}';
  }
}

class PageLine {
  String text;
  TextStyle style;
  double height;

  PageLine(this.text, {required this.style, required this.height});

  @override
  String toString() {
    return 'PageLine{text: $text, height: $height}';
  }
}

// /// 段落
// class BookParagraph {
//   BookParagraph({this.paragraph = "", this.startCharIndex = 0})
//       : endCharIndex = startCharIndex + paragraph.length;
//
//   /// 段落内容
//   final String paragraph;
//
//   /// 文本内容的第几个字节开始
//   final int startCharIndex;
//
//   /// 文本内容的第几个字节结束
//   final int endCharIndex;
// }
