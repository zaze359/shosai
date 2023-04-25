import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/feature/bookshelf/book_list_page.dart';
import 'package:shosai/widgets/search_bar.dart';
import 'package:shosai/routes.dart';

import 'book_search_vm.dart';


/// 书籍搜索页
class BookSearchPage extends StatelessWidget {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    BookSource? bookSource =
        ModalRoute.of(context)?.settings.arguments as BookSource?;
    return ChangeNotifierProvider(
      create: (_) {
        return BookSearchViewModel(bookSource);
      },
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: BookSearchBar(
              hintText: '书名',
              onSubmitted: (v) {
                context.read<BookSearchViewModel>().startSearch(v);
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
          body: Consumer<BookSearchViewModel>(
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
                  .read<BookSearchViewModel>()
                  .startSearch(textEditingController.text);
            },
            child: Icon(Icons.stop),
          ),
        );
      },
    );
  }
}
