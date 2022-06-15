import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_state.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/utils/loader/txt.dart';

import '../log.dart';

class BookLoader {
  final Book _book;

  BookLoader(this._book);

  BookConfig config = BookConfig(0, 0);

  /// 文本加载器
  late final TxtLoader _fileLoader = TxtLoader(_book, config);
  late final BookRepository _bookRepository = BookRepository();

  Future<BookReadingState> initBook() async {
    BookReadingState readingState = BookReadingState(_book);
    List<BookChapter> bookChapters =
        await _bookRepository.queryBookChapters(_book.id);
    if (bookChapters.isEmpty) {
      String localPath = _book.localPath;
      MyLog.d("BookLoader",
          "initBook from local ${_book.name}(${_book.charset}) /$localPath");
      if (localPath.isEmpty) {
        return readingState;
      }
      bookChapters = await _fileLoader.matchChapters();
      await _bookRepository.insertChapters(bookChapters);
      await _bookRepository.insertBook(_book);
    } else {
      MyLog.d(
          "BookLoader", "initBook from db ${_book.name}(${_book.charset})");
    }
    readingState.bookChapters = bookChapters;
    return readingState;
  }

  /// 加载章节状态
  Future<ChapterState> loadChapter(BookChapter? chapter) async {
    if (chapter == null) {
      return ChapterState(chapter);
    }
    return await _fileLoader.loadChapterContent(chapter);
  }

// fun loadPrePage()
//
// fun loadNextPage()
//
// fun loadPreChapter()
// fun loadNextChapter()
//
// fun onLoaded(readerPage: ReaderPage)

}

abstract class ChapterLoader {
  final Book book;
  final BookConfig config;

  ChapterLoader(this.book, this.config);

  /// 匹配章节
  Future<List<BookChapter>> matchChapters();

  /// 加载指定章节内容
  Future<ChapterState> loadChapterContent(BookChapter chapter);

  /// 若存在章节标题则返回标题内容，不存在则返回null
  String? matchTitle(String line);
}

class PageLoader {
  // BookChapter loadPrePage()
  // fun loadNextPage()
}
