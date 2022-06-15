import 'package:flutter/cupertino.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/utils/log.dart';

/// 书本的阅读状态
class BookReadingState {
  BookReadingState(this.book);

  Book? book;
  List<BookChapter> _bookChapters = [];

  /// 当前章节位置
  int chapterIndex = 0;

  set bookChapters(List<BookChapter> value) {
    MyLog.d("BookReadingState", "set bookChapters: ${value.length}");
    _bookChapters = value;
  }

  BookChapter? getCurChapter() {
    if (isOver()) {
      return null;
    }
    return _bookChapters[chapterIndex];
  }

  BookChapter? getNextChapter() {
    if (isLast()) {
      return null;
    }
    return _bookChapters[chapterIndex + 1];
  }

  BookChapter? getPrevChapter() {
    if (isFirst()) {
      return null;
    }
    return _bookChapters[chapterIndex - 1];
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

  bool isFirst() {
    return chapterIndex == 0;
  }

  /// 是否是最后一章
  bool isLast() {
    return chapterIndex == chapterSize - 1;
  }

  bool isOver() {
    return chapterIndex >= _bookChapters.length;
  }

  /// 章节数量
  int get chapterSize {
    return _bookChapters.length;
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
}

/// 阅读页
class PageState {
  PageState([this.lines = const []]);

  List<TextSpan> lines = [];
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
