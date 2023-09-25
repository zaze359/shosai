import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/feature/bookshelf/book_list_page.dart';
import 'package:shosai/widgets/search_bar.dart';
import 'package:shosai/routes.dart';

import 'book_search_vm.dart';


/// 书籍搜索页
class BookSearchPage extends StatefulWidget {

  BookSearchPage({super.key});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  TextEditingController textEditingController = TextEditingController();
  late BookSearchViewModel bookViewModel;


  @override
  void dispose() {
    bookViewModel.stopSearch();
    bookViewModel.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    BookSource? bookSource = ModalRoute.of(context)?.settings.arguments as BookSource?;
    bookViewModel = BookSearchViewModel(bookSource);
    return ChangeNotifierProvider(
      create: (_) {
        return bookViewModel;
      },
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: BookSearchBar(
              hintText: '书名',
              onSubmitted: (v) {
                bookViewModel.startSearch(v);
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
          body: Consumer<BookSearchViewModel>( // 数据发生变化时更新
            builder: (c, mode, _) {
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
              bookViewModel.startSearch(textEditingController.text);
            },
            child: const Icon(Icons.stop),
          ),
        );
      },
    );
  }
}
