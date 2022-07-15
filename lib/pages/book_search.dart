import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/pages/book_list.dart';
import 'package:shosai/pages/search_bar.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/http.dart';

class _BookSearchMode extends ChangeNotifier {
  BookSource? bookSource;
  List<Book> books = [];

  _BookSearchMode(this.bookSource);

  startSearch(String key) async {
    if (key.isEmpty) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "请输入搜索关键字",
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 18.0,
      );
    } else {
      books = await httpHelper.search(bookSource, UrlKeys(key: key));
      notifyListeners();
    }
  }
}

/// 书籍搜索页
class BookSearchPage extends StatelessWidget {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    BookSource? bookSource =
        ModalRoute.of(context)?.settings.arguments as BookSource?;
    return ChangeNotifierProvider(
      create: (_) {
        return _BookSearchMode(bookSource);
      },
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: SearchBar(
              hintText: '书名',
              onSubmitted: (v) {
                context.read<_BookSearchMode>().startSearch(v);
              },
              controller: textEditingController,
            ),
            // actions: [
            //   IconButton(
            //     tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            //     icon: const Icon(
            //       Icons.save_outlined,
            //     ),
            //     onPressed: () {
            //       // BookRepository().updateBookSource(bookSource);
            //     },
            //   ),
            // ],
          ),
          body: Consumer<_BookSearchMode>(
            builder: (c, mode, _) {
              print("mode : ${mode.books}");
              return BookListPage(
                mode.books,
                simple: false,
                onTap: (book) {
                  AppRoutes.startBookDetailPage(context, book);
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context
                  .read<_BookSearchMode>()
                  .startSearch(textEditingController.text);
            },
            child: Icon(Icons.stop),
          ),
        );
      },
    );
  }
}
