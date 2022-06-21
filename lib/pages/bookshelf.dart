import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shosai/data/book.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/file_util.dart';
import 'package:shosai/utils/import.dart' as imports;
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/cache_layout.dart';
import 'package:shosai/widgets/loading_widget.dart';

/// Description : 书架
/// @author zaze
/// @date 2022/6/5 - 01:48
class BookshelfPage extends StatefulWidget {
  BookshelfPage({super.key});

  List<Book> books = [];

  final BookRepository _bookRepository = BookRepository();

  @override
  State<StatefulWidget> createState() {
    return _BookshelfPageState();
  }
}

class _BookshelfPageState extends State<BookshelfPage> {
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

  Future<void> _updateBook(Book book) async {
    await widget._bookRepository.insertOrUpdateBook(book);
    _refreshBookshelf();
  }

  Future<List<Book>> _queryAllBooks() async {
    return widget._bookRepository.queryAllBooks();
  }

  @override
  Widget build(BuildContext context) {
    var books = widget.books;
    // MyLog.i("BookshelfPage", "build: ${books.toString()}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            icon: const Icon(
              Icons.search,
            ),
            onPressed: () {},
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
    return _BookshelfContainer(
      bookRepository: widget._bookRepository,
      child: (books == null || books.isEmpty)
          ? _empty()
          : RefreshIndicator(
              onRefresh: () {
                return _refreshBookshelf();
              },
              child: _grid(3, books),
            ),
    );
  }

  Widget _grid(int count, List<Book> books) {
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: count,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: sqrt1_2,
      children: books
          .map((e) => KeepAliveWrapper(
                child: _BookGridItem(e),
              ))
          .toList(),
    );
  }

  Widget _empty() {
    return Center(
      child: TextButton(
        onPressed: () async {
          _importBookFormLocal();
        },
        child: Text(
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
      if (Platform.isIOS) { // IOS拷贝
        // TODO 需要优化处理，相名文件的处理
        Directory newDir = await FileService.supportDir();
        String newPath = element.absolute.path
            .replaceAll(element.parent.absolute.path, newDir.absolute.path);
        MyLog.i(
            "newPath: ${newPath}");
        widget._bookRepository
            .insertOrUpdateBook(Book.formFile(await element.copy(newPath)));
      } else {
        widget._bookRepository.insertOrUpdateBook(Book.formFile(element));
      }
    }
    _refreshBookshelf();
  }
}

class _BookshelfContainer extends InheritedWidget {
  BookRepository bookRepository;

  _BookshelfContainer({required super.child, required this.bookRepository});

  static _BookshelfContainer of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BookshelfContainer>()!;

  static _BookshelfContainer get(BuildContext context) => context
      .getElementForInheritedWidgetOfExactType<_BookshelfContainer>()!
      .widget as _BookshelfContainer;

  openBook(BuildContext context, Book book) {
    MyLog.d("_BookItem", "_openBook: ${book.name}");
    AppRoutes.pushBookReaderPage(context, book);
    book.latestVisitTime = DateTime.now().millisecondsSinceEpoch;
    _BookshelfNotification(book).dispatch(context);
  }

  @override
  bool updateShouldNotify(_BookshelfContainer oldWidget) {
    return bookRepository != oldWidget.bookRepository;
  }
}

class _BookshelfNotification extends Notification {
  Book _book;

  _BookshelfNotification(this._book);
}

/// 书架页item
class _BookGridItem extends StatelessWidget {
  const _BookGridItem(this._book);

  final Book _book;

  //
  // void _openBook(BuildContext context) {
  //   MyLog.d("_BookItem", "_openBook: ${_book.name}");
  //   AppRoutes.pushBookReaderPage(context, _book);
  //   _BookshelfNotification(_book).dispatch(context);
  // }

  @override
  Widget build(BuildContext context) {
    MyLog.d("_BookGridItem", "build");
    return GestureDetector(
      onTap: () {
        _BookshelfContainer.of(context).openBook(context, _book);
      },
      onLongPress: () {
        MyLog.d("_BookItem", "onLongPress: ${_book.name}");
      },
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: sqrt1_2, // A4 比例 sqrt1_2
            child: Card(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _book.name,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          // Center(
          //   child: Padding(
          //     padding: EdgeInsets.all(4),
          //     child: Text(
          //       _book.name,
          //       maxLines: 2,
          //       overflow: TextOverflow.ellipsis,
          //       style: TextStyle(fontSize: 18),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
