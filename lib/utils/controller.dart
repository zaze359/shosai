import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_state.dart';
import 'package:shosai/utils/loader/loader.dart';
import 'package:shosai/utils/log.dart';

class BookController {
  Book book;

  BookController(this.book);

  /// 书籍加载器
  late BookLoader bookLoader = BookLoader(book);

  /// 更新书籍配置
  void updateBookConfig(BookConfig config) {
    MyLog.d("updateBookConfig", "$config");
    bookLoader.config = config;
  }

  late BookReadingState _readingState = BookReadingState(book);

  /// 上一页
  ChapterState _prevChapter = ChapterState();

  /// 当前页
  ChapterState _curChapter = ChapterState();

  /// 下一页
  ChapterState _nextChapter = ChapterState();

  // Future<BookReadingState> getReadingState() async {
  //   return _readingState ?? await bookLoader.initBook();
  // }

  // Future<ChapterState> getCurChapter() async {
  //   return _curChapter ??
  //       await bookLoader.loadChapter((await getReadingState()).getCurChapter());
  // }
  //
  // Future<ChapterState> getNextChapter() async {
  //   return _nextChapter ??
  //       await bookLoader.loadChapter((await getReadingState()).getNextChapter());
  // }

  // --------------------------------------------------

  Future<PageState> loadBookContent() async {
    _readingState = await bookLoader.initBook();
    _prevChapter = await bookLoader.loadChapter(_readingState.getPrevChapter());
    _curChapter = await bookLoader.loadChapter(_readingState.getCurChapter());
    _nextChapter = await bookLoader.loadChapter(_readingState.getNextChapter());
    return getCurPage();
  }

  /// 获取当前页
  Future<PageState> getCurPage() async {
    return _curChapter.getCurPage();
  }

  /// 获取下一页
  Future<PageState?> getNextPage() async {
    MyLog.d("BookController", "getNextPage");
    if (_curChapter.moveDown()) {
      return _curChapter.getCurPage();
    }
    if (await moveToNextChapter()) {
      return _curChapter.getCurPage();
    }
    return null;
  }

  /// 获取下一页
  Future<PageState?> getPrevPage() async {
    MyLog.d("BookController", "getPrevPage");
    if (_curChapter.moveUp()) {
      return _curChapter.getCurPage();
    }
    if (await moveToPrevChapter()) {
      return _curChapter.getCurPage();
    }
    return null;
  }

  // --------------------------------------------------
  Future<bool> moveToPrevChapter() async {
    if (_readingState.isFirst()) {
      return false;
    }
    _readingState.moveUp();
    _nextChapter = _curChapter;
    _curChapter = _prevChapter;
    _prevChapter = await bookLoader.loadChapter(_readingState.getPrevChapter());
    return true;
  }

  Future<bool> moveToNextChapter() async {
    if (_readingState.isLast()) {
      return false;
    }
    _readingState.moveDown();
    _prevChapter = _curChapter;
    _curChapter = _nextChapter;
    _nextChapter = await bookLoader.loadChapter(_readingState.getNextChapter());
    return true;
  }
}
