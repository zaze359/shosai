
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/service/book_service.dart';
import 'package:shosai/utils/log.dart';

class BookSearchViewModel extends ChangeNotifier {
  /// bookSource == null 表示从所有书源中搜索
  BookSource? bookSource;
  List<Book> books = [];

  BookSearchViewModel(this.bookSource);

  startSearch(String key) async {
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
        notifyListeners();
      } else {
        bookSourceLog("所有源中搜索");
        List<BookSource> searchedSources =
        await BookRepository().queryAllBookSources();
        for (var element in searchedSources) {
          books.addAll(await bookService.search(element, UrlKeys(key: key)));
          notifyListeners();
        }
      }
    }
  }
}
