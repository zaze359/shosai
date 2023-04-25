import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/service/book_service.dart';
import 'package:shosai/utils/custom_event.dart';
import 'package:shosai/utils/file_util.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/book_dialog.dart';
import 'package:shosai/widgets/book_parts.dart';
import 'package:shosai/widgets/loading_widget.dart';

double _paddingLeft = 8;
double _paddingRight = 8;

/// 书籍详情页
class BookDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookDetailPageState();
  }
}

class _BookDetailPageState extends State<BookDetailPage> {
  Book? book;
  BookSource? bookSource;

  @override
  Widget build(BuildContext context) {
    book ??= ModalRoute.of(context)?.settings.arguments as Book?;
    printD("_BookDetailState build: $book");
    return Scaffold(
      appBar: AppBar(
        title: const Text("书籍详情"),
      ),
      body: LoadingBuild<Book?>(
        future: _requestBookInfo(book),
        loading: _body(book),
        success: (c, v) {
          return _body(v ?? book);
        },
      ),
    );
  }

  Future<Book?> _requestBookInfo(Book? book) async {
    if (book == null || book.isLocal()) {
      return book;
    }
    if (bookSource == null) {
      var bookRepository = BookRepository();
      bookSource = await bookRepository.queryBookSource(book.origin);
    }
    return bookService.requestBookInfo(book, bookSource);
  }

  _body(Book? book) {
    if (book == null) {
      return null;
    } else {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BookContainer(book),
                  _divider(10),
                  _TocContainer(book),
                  _divider(),
                  _OriginContainer(book, bookSource),
                  _divider(),
                  _TagContainer(book),
                  _divider(10),
                  _IntroContainer(book),
                ],
              ),
            ),
          ),
          _OperatorWidget(book),
        ],
      );
    }
  }

  Widget _divider([double? h]) {
    return Divider(
      height: h,
      thickness: h,
      indent: 0,
      color: Colors.black12,
    );
  }
}

/// 书籍信息
class _BookContainer extends StatelessWidget {
  final Book book;

  const _BookContainer(this.book);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(_paddingLeft, 8, _paddingRight, 8),
      child: Row(
        children: [
          SizedBox(
            height: 160,
            child: BookCover(book),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 4, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.name ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  if (book.author?.isNotEmpty == true)
                    Text(
                      book.author ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  Text(
                    book.wordCount ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  // Text(
                  //   book.wordCount ?? "",
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: TextStyle(fontSize: 14, color: Colors.black),
                  // ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _OriginContainer extends StatelessWidget {
  final Book book;
  final BookSource? bookSource;

  const _OriginContainer(this.book, this.bookSource);

  @override
  Widget build(BuildContext context) {
    String origin = bookSource?.url ?? book.localPath ?? "";
    return Container(
      constraints: BoxConstraints(minWidth: double.infinity),
      padding: EdgeInsets.fromLTRB(_paddingLeft, 4, _paddingRight, 10),
      child: GestureDetector(
        onTap: () {
          if (bookSource != null) {
            AppRoutes.startSpiderPage(context, bookSource!);
          }
        },
        child: Text(
          "来源: $origin",
          softWrap: true,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

/// 标签
class _TagContainer extends StatelessWidget {
  final Book book;

  const _TagContainer(this.book);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(_paddingLeft, 4, _paddingRight, 10),
      child: BookTag(book),
    );
  }
}

/// 简介
class _IntroContainer extends StatelessWidget {
  final Book book;

  const _IntroContainer(this.book);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(_paddingLeft, 12, _paddingRight, 12),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "简介",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Text(
              book.intro ?? "",
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }
}

class _TocContainer extends StatefulWidget {
  final Book book;

  const _TocContainer(this.book);

  @override
  State<StatefulWidget> createState() {
    return _TocContainerState();
  }
}

class _TocContainerState extends State<_TocContainer> {
  List<BookChapter> tocList = [];
  String? latestChapterTitle;

  Future<String?> _loadToc() async {
    if (widget.book.isLocal()) {
      //
    } else {
      BookRepository bookRepository = BookRepository();
      BookSource? bookSource =
          await bookRepository.queryBookSource(widget.book.origin);
      tocList = await bookService.requestToc(widget.book, bookSource);
      await bookRepository.insertChapters(tocList);
      if (tocList.isNotEmpty) {
        latestChapterTitle = tocList[0].title;
      }
    }
    return latestChapterTitle;
  }

  @override
  Widget build(BuildContext context) {
    printD("_TocContainerState build latestChapterTitle: $latestChapterTitle");
    return TextButton(
      // style: TextButton.styleFrom(
      //   padding: EdgeInsets.fromLTRB(paddingLeft, 0, paddingRight, 0),
      // ),
      onPressed: () {
        if (tocList.isNotEmpty) {
          AppRoutes.startBookTocPage(context, widget.book);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "目录",
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: LoadingBuild<String?>(
                future: _loadToc(),
                loading: const Text(
                  "加载中...",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                success: (c, v) {
                  return Text(
                    v ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const Icon(
            Icons.navigate_next_outlined,
            color: Colors.black,
          )
        ],
      ),
    );
  }
}

class _OperatorWidget extends StatefulWidget {
  final Book book;
  bool inBookShelf = false;

  _OperatorWidget(this.book);

  @override
  State<StatefulWidget> createState() {
    return _OperatorWidgetState();
  }
}

class _OperatorWidgetState extends State<_OperatorWidget> {
  _addToBookShelf(Book book) async {
    printD("_addToBookShelf");
    await BookRepository().insertOrUpdateBook(book);
    eventBus.fire(BookEvent.addBook(book));
    setState(() {
      widget.inBookShelf = true;
    });
  }

  _removeFromBookShelf(Book book) async {
    printD("_removeFromBookShelf");
    return showDialog(
      context: context,
      builder: (_) => DeleteBookDialog(book, (bool deleteFile) {
        _deleteBook(book, deleteFile);
      }),
    );
  }

  /// 删除书籍
  Future<void> _deleteBook(Book book, bool deleteFile) async {
    MyLog.d("_BookItem", "_deleteBook: ${book.name}; deleteFile: $deleteFile");
    if (deleteFile) {
      if (book.isLocal()) {
        FileService.deleteFile(book.localPath);
      } else {
        FileService.deleteDirectory(await bookService.localDir(book.id), recursive: true);
      }
    }
    await BookRepository().deleteBook(book);
    eventBus.fire(BookEvent.removeBook(book));
    setState(() {
      widget.inBookShelf = false;
    });
  }

  Future<bool> _isInBookShelf() async {
    var bookRepository = BookRepository();
    widget.inBookShelf =
        (await bookRepository.queryBook(widget.book.id)).isNotEmpty;
    printD("_requestBookInfo inBookShelf: ${widget.inBookShelf}");
    return widget.inBookShelf;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingBuild<bool>(
      future: _isInBookShelf(),
      success: (c, v) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.inBookShelf) {
                      _removeFromBookShelf(widget.book);
                    } else {
                      _addToBookShelf(widget.book);
                    }
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: Text(widget.inBookShelf ? "移除书架" : "加入书架"),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () {
                    AppRoutes.startBookReaderPage(context, widget.book);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: Text("阅读"),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
