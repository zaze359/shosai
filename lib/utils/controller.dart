import 'dart:async';

import 'package:shosai/core/model/book.dart';
import 'package:shosai/core/model/book_state.dart';
import 'package:shosai/utils/loader/loader.dart';
import 'package:shosai/utils/log.dart';

BookController bookController = BookController();

class BookController {
  BookController._internal();

  static final BookController _instance = BookController._internal();

  factory BookController() => _instance;

  bool _initialized = false;

  List<Book> books = [];

  /// 书籍加载器
  BookLoader? _bookLoader;

  /// 阅读状态
  BookState? _bookState;

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

  int get chapterSize => _bookState?.chapterSize ?? 0;

  bool get isLastChapter => _bookState?.isLast() ?? true;

  bool get isFirstChapter => _bookState?.isFirst() ?? true;

  BookChapter? get curChapter => _bookState?.getCurChapter();

  int get chapterIndex => _bookState?.chapterIndex ?? 0;

  set book(Book? book) {
    MyLog.d("BookController", "setBook pre: $_book; new: $book");
    if (_book?.id == book?.id) {
      return;
    }
    _initialized = false;
    _book = book;
    _bookLoader = null;
    _bookState = null;
    _prevChapter = null;
    _curChapter = null;
    _nextChapter = null;
    if (book != null) {
      _bookLoader = BookLoader(book);
      _bookState = BookState(book);
    }
  }

  Future<List<BookChapter>> getBookChapters() async {
    return _bookState?.bookChapters ?? [];
  }

  Future<PageState> reload() async {
    MyLog.d("BookController",
        "reload delete: ${(await _bookLoader?.clearBookChapters())}");
    _bookState?.bookChapters = [];
    _bookState?.chapterIndex = 0;
    _initialized = false;
    return loadHistoryPage();
  }

  /// 初始化
  init([Book? book]) async {
    if(book != null && this.book != book) {
      this.book = book;
    }
    MyLog.d("BookController", "init: $_initialized");
    if (!_initialized) {
      _bookState = await _bookLoader?.initBook();
      _initialized = true;
    }
    return _bookState;
  }

  Future<ChapterState?> loadHistoryChapter() async {
    MyLog.d("BookController", "loadHistoryPage: $_initialized");
    init();
    return await loadCurChapter();
  }

  Future<ChapterState?> loadCurChapter() async {
    BookChapter? bookChapter = _bookState?.getCurChapter();
    _curChapter ??= await _bookLoader?.loadChapter(bookChapter);
    MyLog.d("BookController", "loadCurChapter: $_curChapter");
    await preLoad();
    return _curChapter;
  }

  Future<ChapterState?> loadNextChapter() async {
    _nextChapter ??=
        await _bookLoader?.loadChapter(_bookState?.getNextChapter());
    MyLog.d("BookController", "loadNextChapter: $_nextChapter");
    return _nextChapter;
  }

  Future<ChapterState?> loadPreChapter() async {
    _prevChapter ??=
        await _bookLoader?.loadChapter(_bookState?.getPrevChapter());
    MyLog.d("BookController", "loadPreChapter: $_curChapter");
    return _prevChapter;
  }

  Future<ChapterState?> loadChapter(int chapterIndex) async {
    MyLog.d("BookController", "loadPreChapter: $chapterIndex");
    switch (chapterIndex - (_bookState?.chapterIndex ?? 0)) {
      case 0:
        return loadCurChapter();
      case -1:
        return loadPreChapter();
      case 1:
        return loadNextChapter();
      default:
        return _bookLoader?.loadChapter(_bookState?.getChapter(chapterIndex));
    }
  }

  preLoad() async {
    // MyLog.d("BookController", "preLoad start");
    // await loadNextChapter();
    // await loadPreChapter();
    // MyLog.d("BookController", "preLoad end");
  }

  // --------------------------------------------------
  // --------------------------------------------------
  Future<PageState> loadHistoryPage() async {
    return (await loadHistoryChapter())?.getCurPage() ?? PageState.empty();
  }

  Future<PageState> loadCurPage() async {
    _curChapter ??= await _bookLoader?.loadChapter(_bookState?.getCurChapter());
    // 不必等待
    preLoad();
    MyLog.d("BookController", "_curChapter: $_curChapter");
    return _curChapter?.getCurPage() ?? PageState.empty();
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
        "moveToPrevChapter: ${(_bookState?.chapterIndex ?? 0) - 1}");
    if (_bookState?.isFirst() == true) {
      return false;
    }
    _bookState?.moveUp();
    _nextChapter = _curChapter;
    _nextChapter?.toFirstPage();
    _curChapter = _prevChapter;
    _curChapter?.toFirstPage();
    _prevChapter = null;
    return true;
  }

  bool moveToNextChapter() {
    MyLog.d("BookController",
        "moveToNextChapter: ${(_bookState?.chapterIndex ?? 0) + 1}");
    if (_bookState?.isLast() == true) {
      return false;
    }
    _bookState?.moveDown();
    _prevChapter = _curChapter;
    _prevChapter?.toFirstPage();
    _curChapter = _nextChapter;
    _curChapter?.toFirstPage();
    _nextChapter = null;
    return true;
  }

  void moveToChapter(int index) {
    moveSomeChapter(index - (_bookState?.chapterIndex ?? 0));
  }

  bool moveSomeChapter(int offset) {
    MyLog.d(
        "BookController moveSomeChapter move ${_bookState?.chapterIndex ?? 0} to ${(_bookState?.chapterIndex ?? 0) + offset}");
    switch (offset) {
      case 0: // 当前章节
        return false;
      case 1: // 下一章节
        return moveToNextChapter();
      case -1: // 上一章节
        return moveToPrevChapter();
      default:
        _bookState?.moveTo(offset + (_bookState?.chapterIndex ?? 0));
        _nextChapter = null;
        _curChapter = null;
        _prevChapter = null;
        return true;
    }
  }


  bool isInBookShelf(String bookId) {
    return books.indexWhere((element) => element.id == bookId) > 0;
  }
}
