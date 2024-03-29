import 'dart:async';

import 'package:shosai/core/common/di.dart';
import 'package:shosai/core/data/repository/book_repository.dart';
import 'package:shosai/core/model/book.dart';
import 'package:shosai/core/model/book_config.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/core/model/book_state.dart';
import 'package:shosai/service/book_service.dart';
import 'package:shosai/utils/loader/txt_loader.dart';
import 'package:shosai/utils/reg_exp.dart' as reg_exp;

import '../log.dart';

class BookLoader {
  final Book _book;

  BookSource? bookSource;

  BookLoader(this._book);

  /// 文本加载器
  late final TxtLoader _fileLoader = TxtLoader(_book, bookConfig);
  late final BookRepository _bookRepository = Injector.instance.get<BookRepository>();

  final Set<int> _loadingChapter = {};

  Future<int> clearBookChapters() async {
    return await _bookRepository.clearBookChapters(_book.id);
  }

  Future<BookState> initBook() async {
    MyLog.d("BookLoader", "initBook start ${_book.name}");
    BookState readingState = BookState(_book);
    List<BookChapter> bookChapters =
        await _bookRepository.queryBookChapters(_book.id);
    MyLog.d(
        "BookLoader", "queryBookChapters from db: find ${bookChapters.length}");
    if (_book.isRemote()) {
      MyLog.d("BookLoader", "initBook from remote: load bookSource");
      bookSource ??= await _bookRepository.queryBookSource(_book.origin);
    } else if (bookChapters.isEmpty) {
      // 本地书籍，并且当前无章节信息
      String? localPath = _book.localPath;
      MyLog.d("BookLoader", "initBook from local $localPath");
      if (localPath == null || localPath.isEmpty) {
        return readingState;
      }
      bookChapters = await _matchChapters();
      await _bookRepository.insertChapters(bookChapters);
      await _bookRepository.insertOrUpdateBook(_book);
    }
    readingState.bookChapters = bookChapters;
    MyLog.d("BookLoader", "initBook end ${_book.name}(${_book.charset})");
    return readingState;
  }

  Future<bool> _downloadChapter(
      BookSource? bookSource, List<BookChapter> chapters) {
    if (chapters.isEmpty) {
      return Future.value(false);
    }
    Completer<bool> completer = Completer();
    for (var chapter in chapters) {
      bookService.downloadChapter(
        bookSource,
        chapter,
        onStart: (total) {
          MyLog.d("_downloadChapter ${chapter.title} onStart");
        },
        onSuccess: (savePath) {
          MyLog.d("_downloadChapter ${chapter.title} onSuccess");
          chapter.localPath = savePath;
          completer.complete(true);
        },
        onFailure: (code, msg, savePath) {
          MyLog.d("_downloadChapter ${chapter.title} onFailure: $msg($code)");
          completer.complete(false);
        },
      );
    }
    return completer.future;
  }

  /// 正则格式化章节内容
  Future<List<BookChapter>> _matchChapters() async {
    List<BookChapter> bookChapters = [];
    for (var regExp in reg_exp.tocRegExpList) {
      MyLog.d("BookLoader", "initBook regExp：$regExp");
      // 若匹配的章节过少则，换一个规则重新匹配。
      bookChapters = await _fileLoader.matchChapters(regExp);
      if (bookChapters.length > 3) {
        break;
      }
      // else if (bookChapters.isNotEmpty &&
      //     bookChapters[bookChapters.length - 1].charEnd < 524288) {
      //   // 虽然仅有几章，但是内容不多，不考虑重新匹配。
      //   break;
      // }
    }
    return bookChapters;
  }

  /// 加载章节状态
  Future<ChapterState?> loadChapter(BookChapter? chapter) async {
    // MyLog.d("BookLoader", "loadChapter start: $chapter");
    if (chapter == null) {
      return null;
    }
    _loadingChapter.add(chapter.index);
    String? path;
    if (_book.isRemote()) {
      // 远程书籍，需要下载
      bookSource ??= await _bookRepository.queryBookSource(_book.origin);
      await _downloadChapter(bookSource, [chapter]);
      path = chapter.localPath;
    } else {
      path = _book.localPath;
    }
    if (_fileLoader.config.isAvoid()) {
      // 当前配置不可用，暂不加载章节。
      // 配置会在打开BookReadPage 时被更新。
      return null;
    }
    return _fileLoader.loadChapterContent(path, chapter).then((value) {
      // MyLog.d("BookLoader", "loadChapter end: $chapter");
      _loadingChapter.remove(chapter.index);
      return value;
    });
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
  /// 将书籍内容按照章节拆分开
  Future<List<BookChapter>> matchChapters(RegExp regExp);

  /// 加载指定章节内容
  /// 将章节内容分页
  /// 页内分行
  Future<ChapterState> loadChapterContent(String? path, BookChapter chapter);
}

class PageLoader {
  // BookChapter loadPrePage()
  // fun loadNextPage()
}
