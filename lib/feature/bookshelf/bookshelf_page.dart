import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/feature/bookshelf/book_list_page.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/custom_event.dart';
import 'package:shosai/utils/file_util.dart';
import 'package:shosai/utils/import.dart' as imports;
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/loading_widget.dart';

/// Description : 书架
/// @author zaze
/// @date 2022/6/5 - 01:48
class BookshelfPage extends StatefulWidget {
  BookshelfPage({super.key});

  final List<Book> books = [];

  final BookRepository _bookRepository = BookRepository();

  @override
  State<StatefulWidget> createState() {
    return _BookshelfPageState();
  }
}

class _BookshelfPageState extends State<BookshelfPage> {
  StreamSubscription? subscription;

  /// 更新书架
  Future<void> _refreshBookshelf() async {
    var newList = await _queryAllBooks();
    setState(() {
      widget.books.clear();
      if (newList.isNotEmpty) {
        widget.books.addAll(newList);
      }
    });
  }

  openBook(Book book) {
    _updateBook(book);
    AppRoutes.startBookReaderPage(context, book);
  }

  Future<void> _updateBook(Book book) async {
    book.latestVisitTime = DateTime.now().millisecondsSinceEpoch;
    // MyLog.d("_BookItem", "_openBook: ${book.name}");
    await widget._bookRepository.insertOrUpdateBook(book);
    _refreshBookshelf();
  }

  showBookDetail(Book book) {
    AppRoutes.startBookDetailPage(context, book);
  }

  Future<void> _dealEvent(BookEvent event) async {
    MyLog.d("_BookItem", "_dealEvent: $event;");
    return _refreshBookshelf();
  }

  Future<List<Book>> _queryAllBooks() async {
    return widget._bookRepository.queryAllBooks();
  }

  @override
  void initState() {
    super.initState();
    subscription = eventBus.on<BookEvent>().listen((event) {
      _dealEvent(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    // var books = widget.books;
    // MyLog.i("BookshelfPage", "build: ${books.toString()}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            icon: const Icon(
              Icons.search,
            ),
            onPressed: () async {
              AppRoutes.startBookSearchPage(context);
            },
          ),
          PopupMenuButton<Text>(
            position: PopupMenuPosition.under,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    _importBookFormLocal();
                  },
                  child: Text("导入"),
                ),
                // const PopupMenuItem(
                //   child: Text(
                //     "导出",
                //   ),
                // ),
              ];
            },
          )
        ],
      ),
      body: NotificationListener<_BookshelfNotification>(
        onNotification: (notification) {
          _updateBook(notification._book);
          return true;
        },
        child: LoadingBuild.circle(
          future: _queryAllBooks(),
          success: (BuildContext context, List<Book>? value) {
            return _showBookshelf(value);
          },
        ),
      ),
    );
  }

  Widget _showBookshelf(List<Book>? books) {
    return (books == null || books.isEmpty)
        ? _empty()
        : RefreshIndicator(
            onRefresh: () {
              return _refreshBookshelf();
            },
            child: BookListPage(
              books,
              onLongPress: showBookDetail,
              onTap: openBook,
            ),
          );
  }

  //
  Widget _empty() {
    return Center(
      child: TextButton(
        onPressed: () async {
          _importBookFormLocal();
        },
        child: const Text(
          "导入书籍",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  /// 从本地导入书籍
  void _importBookFormLocal() async {
    List<File> files = await imports.importBookFormLocal();
    for (File element in files) {
      if (Platform.isIOS) {
        // IOS拷贝
        // TODO 需要优化处理，相名文件的处理
        String newPath = element.absolute.path.replaceAll(
            element.parent.absolute.path, await FileService.supportDir());
        widget._bookRepository
            .insertOrUpdateBook(Book.formFile(await element.copy(newPath)));
      } else {
        widget._bookRepository.insertOrUpdateBook(Book.formFile(element));
      }
    }
    _refreshBookshelf();
  }
}

class _BookshelfNotification extends Notification {
  Book _book;

  _BookshelfNotification(this._book);
}
