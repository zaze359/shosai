import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/pages/book_list.dart';
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

  showDeleteDialog(Book book) {
    return showDialog(
      context: context,
      builder: (_) => _DeleteBookDialog(book, (bool deleteFile) {
        _deleteBook(book, deleteFile);
      }),
    );
  }

  Future<void> _deleteBook(Book book, bool deleteFile) async {
    // MyLog.d("_BookItem", "_deleteBook: ${book.name}; deleteFile: $deleteFile");
    await widget._bookRepository.deleteBook(book);
    if (deleteFile) {
      FileService.deleteFile(book.localPath);
    }
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
        title: const Text('书架'),
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            icon: const Icon(
              Icons.search,
            ),
            onPressed: () async {
              AppRoutes.startBookSearchPage(context,
                  (await BookRepository().queryAllBookSources()).first);
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
              onLongPress: showDeleteDialog,
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
      if (Platform.isIOS) {
        // IOS拷贝
        // TODO 需要优化处理，相名文件的处理
        Directory newDir = await FileService.supportDir();
        String newPath = element.absolute.path
            .replaceAll(element.parent.absolute.path, newDir.absolute.path);
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

class _DeleteBookDialog extends StatelessWidget {
  _DeleteBookDialog(this._book, this.deleteFunc);

  Book _book;
  bool _deleteFile = false;
  Function(bool) deleteFunc;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_book.name ?? ""),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("确认删除?"),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "从设备上删除源文件",
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                  strutStyle: StrutStyle(
                    forceStrutHeight: true,
                  ),
                ),
                StatefulBuilder(builder: (context, setState) {
                  return Checkbox(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                    ),
                    value: _deleteFile,
                    onChanged: (bool? value) {
                      setState(() {
                        _deleteFile = value == true;
                      });
                    },
                  );
                }),
              ],
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("取消"),
        ),
        TextButton(
          onPressed: () {
            deleteFunc(_deleteFile);
            Navigator.of(context).pop();
          },
          child: const Text("删除"),
        ),
      ],
    );
  }
}
