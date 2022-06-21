import 'dart:async';

import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_state.dart';
import 'package:shosai/utils/loader/loader.dart';
import 'package:shosai/utils/log.dart';

BookController bookController = BookController();

class BookController {
  BookController._internal();

  static final BookController _instance = BookController._internal();

  factory BookController() => _instance;

  bool _initialized = false;

  /// 书籍加载器
  BookLoader? _bookLoader;

  /// 阅读状态
  BookReadingState? _readingState;

  /// 上一页
  ChapterState? _prevChapter;

  /// 当前页
  ChapterState? _curChapter;

  /// 下一页
  ChapterState? _nextChapter;

  /// 书籍信息
  Book? _book;

  Book? get book {
    return _book;
  }

  BookChapter? get curChapter => _readingState?.getCurChapter();

  int get chapterIndex => _readingState?.chapterIndex ?? 0;

  set book(Book? book) {
    MyLog.d("BookController", "setBook pre: $_book; new: $book");
    if (_book?.id == book?.id) {
      return;
    }
    _initialized = false;
    _book = book;
    _bookLoader = null;
    _readingState = null;
    _prevChapter = null;
    _curChapter = null;
    _nextChapter = null;
    if (book != null) {
      _bookLoader = BookLoader(book);
      _readingState = BookReadingState(book);
    }
  }

  List<BookChapter> getBookChapters() {
    return _readingState?.bookChapters ?? [];
  }

  Future<PageState> reload() async {
    MyLog.d("BookController",
        "reload delete: ${(await _bookLoader?.clearBookChapters())}");
    _readingState?.bookChapters = [];
    _readingState?.chapterIndex = 0;
    _initialized = false;
    return loadHistoryPage();
  }

  Future<PageState> loadHistoryPage() async {
    MyLog.d("BookController", "loadHistoryPage: $_initialized");
    if (!_initialized) {
      _readingState = await _bookLoader?.initBook();
      _initialized = true;
    }
    return await loadCurPage();
  }

  preLoad() async {
    // MyLog.d("BookController", "preLoad start");
    // _nextChapter ??=
    //     await _bookLoader?.loadChapter(_readingState?.getNextChapter());
    // _prevChapter ??=
    //     await _bookLoader?.loadChapter(_readingState?.getPrevChapter());
    // MyLog.d("BookController", "preLoad end");
  }

  Future<PageState> loadCurPage() async {
    _curChapter ??=
        await _bookLoader?.loadChapter(_readingState?.getCurChapter());
    // 不必等待
    preLoad();
    MyLog.d("BookController", "_curChapter: $_curChapter");
    return _curChapter?.getCurPage() ?? PageState();
  }

  /// 获取下一页
  Future<PageState?> getNextPage() async {
    MyLog.d("BookController", "getNextPage");
    if (_curChapter?.moveDown() == true) {
      return _curChapter?.getCurPage();
    }
    if (moveToNextChapter()) {
      return loadCurPage();
    }
    return null;
  }

  /// 获取上一页
  Future<PageState?> getPrevPage() async {
    MyLog.d("BookController", "getPrevPage");
    if (_curChapter?.moveUp() == true) {
      return _curChapter?.getCurPage();
    }
    if (moveToPrevChapter()) {
      _curChapter?.toLastPage();
      return loadCurPage();
    }
    return null;
  }

  // --------------------------------------------------
  bool moveToPrevChapter() {
    MyLog.d("BookController",
        "moveToPrevChapter: ${(_readingState?.chapterIndex ?? 0) - 1}");
    if (_readingState?.isFirst() == true) {
      return false;
    }
    _readingState?.moveUp();
    _nextChapter = _curChapter;
    _nextChapter?.toFirstPage();
    _curChapter = _prevChapter;
    _curChapter?.toFirstPage();
    _prevChapter = null;
    return true;
  }

  bool moveToNextChapter() {
    MyLog.d("BookController",
        "moveToNextChapter: ${(_readingState?.chapterIndex ?? 0) + 1}");
    if (_readingState?.isLast() == true) {
      return false;
    }
    _readingState?.moveDown();
    _prevChapter = _curChapter;
    _prevChapter?.toFirstPage();
    _curChapter = _nextChapter;
    _curChapter?.toFirstPage();
    _nextChapter = null;
    return true;
  }

  void moveToChapter(int index) {
    int offset = index - (_readingState?.chapterIndex ?? 0);
    MyLog.d("BookController",
        "moveToChapter chapterIndex: $index; curChapterIndex: ${_readingState?.chapterIndex}, offset: $offset");
    switch (offset) {
      case 0: // 当前章节
        return;
      case 1: // 下一章节
        moveToNextChapter();
        break;
      case -1: // 上一章节
        moveToPrevChapter();
        break;
      default:
        _readingState?.moveTo(index);
        _nextChapter = null;
        _curChapter = null;
        _prevChapter = null;
        break;
    }
  }
}
