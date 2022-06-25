import 'package:flutter/cupertino.dart';
import 'package:shosai/data/book.dart';

/// 书本的阅读状态
class BookState {
  BookState(this.book);

  Book? book;
  List<BookChapter> bookChapters = [];

  /// 当前章节位置
  int chapterIndex = 0;

  BookChapter? getChapter(int chapterIndex) {
    if (chapterIndex < 0 || chapterIndex >= bookChapters.length) {
      return null;
    }
    return bookChapters[chapterIndex];
  }

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

/// 阅读页
class PageState {
  PageState(this.pageIndex,
      {required this.bookName,
      required this.chapterIndex,
      required this.chapterTitle,
      required this.chapterSize});

  PageState.fromChapter(this.pageIndex, ChapterState chapterState)
      : bookName = chapterState.bookName,
        chapterIndex = chapterState.chapterIndex,
        chapterTitle = chapterState.title,
        chapterSize = chapterState.pages.length;

  PageState.empty()
      : pageIndex = 0,
        bookName = "",
        chapterIndex = 0,
        chapterTitle = "",
        chapterSize = 1;

  List<PageLine> lines = [];

  // 默认将空白部分均匀的分配到每一行直接。
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceBetween;

  int pageIndex;
  String bookName;
  String chapterTitle;
  int chapterSize;
  int chapterIndex;

  // ConnectionState state = ConnectionState.done;

  bool get isNotEmpty => lines.isNotEmpty;

  @override
  String toString() {
    return 'PageState{pageIndex: $pageIndex, bookName: $bookName, chapterTitle: $chapterTitle, chapterSize: $chapterSize, chapterIndex: $chapterIndex}';
  }
}

/// 章节内容
class ChapterState {
  ChapterState(this.bookName, this.title, this.chapterIndex);

  String bookName;
  int chapterIndex;
  String title;

  List<PageState> pages = [];

  void addPage(PageState pageState) {
    pages.add(pageState);
  }

  /// 当前章节的第几页
  int pageIndex = 0;

  PageState getCurPage() {
    if (isOver()) {
      return PageState.fromChapter(pageIndex, this);
    }
    return pages[pageIndex];
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
    return pageIndex == pages.length - 1;
  }

  bool isOver() {
    return pageIndex >= pages.length;
  }

  /// 到第一页
  void toFirstPage() {
    pageIndex = 0;
  }

  /// 到最后一页
  void toLastPage() {
    pageIndex = pages.length - 1;
  }

  @override
  String toString() {
    return 'ChapterState: $title: (${pages.length} - $pageIndex)';
  }
}

class PageLine {
  String text;
  TextStyle style;
  double height;
  bool isTitle;

  PageLine(this.text,
      {required this.style, required this.height, this.isTitle = false}) {
    if (isTitle) {
      text = text.trim();
    }
  }

  @override
  String toString() {
    return 'PageLine{text: $text, height: $height}';
  }
}
