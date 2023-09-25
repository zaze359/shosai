import 'package:flutter/material.dart';
import 'package:shosai/core/common/di.dart';
import 'package:shosai/core/data/repository/book_repository.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/tip.dart';

class SpiderMode extends ChangeNotifier {
  BookSource bookSource;
  BookRepository bookRepository = Injector.instance.get<BookRepository>();

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
    bookRepository.updateBookSource(bookSource).then((value) {
      this.bookSource = bookSource;
      showSnackBar(context, '书源更新成功!');
    });
  }
}
