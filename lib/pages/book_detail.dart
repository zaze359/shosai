import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/http.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/book_parts.dart';
import 'package:shosai/widgets/loading_widget.dart';

/// 书籍详情页
class BookDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookDetailPageState();
  }
}

class _BookDetailPageState extends State<BookDetailPage> {
  Book? book;

  @override
  Widget build(BuildContext context) {
    book ??= ModalRoute.of(context)?.settings.arguments as Book?;
    printD("_BookDetailState build: $book");
    return Scaffold(
      appBar: AppBar(
        title: const Text("书籍详情"),
      ),
      body: LoadingBuild<Book?>.circle(
        future: _requestBookInfo(book),
        success: (c, v) {
          return _body(v);
        },
      ),
    );
  }

  Future<Book?> _requestBookInfo(Book? book) async {
    if (book == null) {
      return book;
    }
    BookSource? bookSource =
        await BookRepository().queryBookSource(book.origin);
    return httpHelper.requestBookInfo(book, bookSource);
  }

  _body(Book? book) {
    double paddingLeft = 8;
    double paddingRight = 8;
    if (book == null) {
      return null;
    } else {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(paddingLeft, 8, paddingRight, 8),
              child: Row(
                children: [
                  SizedBox(
                    height: 160,
                    child: BookCover(book),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 4, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.name ?? "",
                          style: TextStyle(fontSize: 16, color: Colors.black),
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
                  )
                ],
              ),
            ),
            const Divider(
              height: 10,
              thickness: 10,
              indent: 0,
              color: Colors.black12,
            ),
            _TocContainer(book),
            const Divider(
              color: Colors.black12,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(paddingLeft, 4, paddingRight, 10),
              child: BookTag(book),
            ),
            const Divider(
              height: 10,
              thickness: 10,
              indent: 0,
              color: Colors.black12,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(paddingLeft, 12, paddingRight, 12),
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
            )
          ],
        ),
      );
    }
  }
}

class _TocContainer extends StatefulWidget {
  Book book;

  _TocContainer(this.book);

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
      tocList = await httpHelper.requestToc(widget.book, bookSource);
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
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
