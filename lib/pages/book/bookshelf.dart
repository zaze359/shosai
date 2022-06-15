import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/log.dart';

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

  Future<List<Book>> _queryAllBooks() async {
    return widget._bookRepository.queryAllBooks();
  }

  @override
  Widget build(BuildContext context) {
    var books = widget.books;
    MyLog.i("BookshelfPage", "build: ${books.toString()}");
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
                const PopupMenuItem(
                  child: Text(
                    "导出",
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _queryAllBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _showBookshelf(snapshot.data);
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      // body: widget.books.isEmpty ? _empty() : grid(2, widget.books),
    );
  }

  Widget _showBookshelf(List<Book>? books) {
    return (books == null || books.isEmpty)
        ? _empty()
        : RefreshIndicator(
            onRefresh: () {
              return _refreshBookshelf();
            },
            child: _grid(2, books),
          );
  }

  Widget _grid(int count, List<Book> books) {
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: count,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.5,
      children: books.map((e) => _BookGridItem(e)).toList(),
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
    var state = await Permission.manageExternalStorage.request();
    if (state.isGranted) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        MyLog.d("importBookFormLocal", "selectedDirectory: $selectedDirectory");
        Directory(selectedDirectory).listSync().where((element) {
          MyLog.d("importBookFormLocal", "book file: ${element.absolute.path}");
          return element.absolute.path.endsWith(".txt");
        }).forEach((element) {
          var file = File(element.absolute.path);
          widget._bookRepository.insertBook(Book.formFile(file));
        });
        await _refreshBookshelf();
      }
    }
  }
}

/// 书架页item
class _BookGridItem extends StatelessWidget {
  const _BookGridItem(this._book);

  final Book _book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MyLog.d("_BookItem", "onTap: ${_book.name}");
        AppRoutes.pushBookReaderPage(context, _book);
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
          Center(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Text(
                _book.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
