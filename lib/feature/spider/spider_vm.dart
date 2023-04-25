import 'package:flutter/material.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/tip.dart';

class SpiderMode extends ChangeNotifier {
  BookSource bookSource;

  TextStyle inputTextStyle = const TextStyle(fontSize: 18, color: Colors.white);

  SpiderMode(this.bookSource);

  addParam(UrlParam param) {
    bookSource.searchUrl.params.add(param);
    printD("addParam: $param");
  }

  startSearch(BuildContext context) {
    AppRoutes.startBookSearchPage(context, bookSource);
  }

  updateBookSource(BuildContext context, bookSource) {
    BookRepository().updateBookSource(bookSource).then((value) {
      this.bookSource = bookSource;
      showSnackBar(context, '书源更新成功!');
    });
  }
}
