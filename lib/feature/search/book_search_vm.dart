import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shosai/core/common/di.dart';
import 'package:shosai/core/data/repository/book_repository.dart';
import 'package:shosai/core/model/book.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/service/book_service.dart';
import 'package:shosai/utils/log.dart';

class BookSearchViewModel extends ChangeNotifier {
  /// bookSource == null 表示从所有书源中搜索
  BookSource? bookSource;
  List<Book> books = [];

  BookSearchViewModel(this.bookSource);
  CancelableOperation<void>? searchOperation;
  BookRepository bookRepository = Injector.instance.get<BookRepository>();

  String? _latelyKey;

  startSearch(String key) {
    if(_latelyKey != key) {
      books.clear();
      stopSearch();
      searchOperation = CancelableOperation<void>.fromFuture(_startSearch(key));
    }
  }

  stopSearch() {
    searchOperation?.cancel();
    _latelyKey = null;
  }

  _startSearch(String key) async {
    _latelyKey = key;
    print("startSearch: $key");
    if (key.isEmpty) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "请输入搜索关键字",
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 18.0,
      );
    } else {
      if (bookSource != null) {
        bookSourceLog("指定源中搜索：$bookSource");
        books = await bookService.search(bookSource, UrlKeys(key: key));
        await bookRepository.updateBookSource(bookSource);
        notifyListeners();
      } else {
        bookSourceLog("所有源中搜索");
        List<BookSource> searchedSources =
            await bookRepository.queryAllBookSources();
        for (var element in searchedSources) {
          books.addAll(await bookService.search(element, UrlKeys(key: key)));
          await bookRepository.updateBookSource(element);
          notifyListeners();
        }
      }
    }
  }
}
