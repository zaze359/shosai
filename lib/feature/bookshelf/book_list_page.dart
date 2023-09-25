import 'package:flutter/material.dart';
import 'package:shosai/core/model/book.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/book_parts.dart';
import 'package:shosai/widgets/cache_layout.dart';

typedef BookLongPressCallback = void Function(Book book);
typedef BookTapCallback = void Function(Book book);

class BookListPage extends StatelessWidget {
  final List<Book> books;
  final bool simple;

  final BookLongPressCallback? onLongPress;
  final BookTapCallback? onTap;

  const BookListPage(this.books,
      {super.key, this.simple = true, this.onLongPress, this.onTap});

  @override
  Widget build(BuildContext context) {
    return simple ? _grid() : _list();
  }

  Widget _grid() {
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 3,
      // mainAxisSpacing: 8,
      // crossAxisSpacing: 8,
      childAspectRatio: 0.5,
      children: books
          .map((e) => KeepAliveWrapper(
              child: _BookGridItem(
                e,
                onLongPress: onLongPress,
                onTap: onTap,
              ),
            ),
          ).toList(),
    );
  }

  Widget _list() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: books.length,
      itemExtent: 160,
      itemBuilder: (c, i) {
        return KeepAliveWrapper(
          child: _BookListItem(
            books[i],
            onLongPress: onLongPress,
            onTap: onTap,
          ),
        );
      },
    );
  }
}

/// 书架页item
class _BookGridItem extends StatelessWidget {
  final Book _book;
  final BookLongPressCallback? onLongPress;
  final BookTapCallback? onTap;

  const _BookGridItem(this._book, {this.onLongPress, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call(_book);
      },
      onLongPress: () {
        onLongPress?.call(_book);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            BookCover(_book),
            const Padding(padding: EdgeInsets.fromLTRB(0, 4, 0, 0)),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                _book.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "未读",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// 书架页item
class _BookListItem extends StatelessWidget {
  final Book _book;
  final BookLongPressCallback? onLongPress;
  final BookTapCallback? onTap;

  const _BookListItem(this._book, {this.onLongPress, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        printD("build: onTap: ${_book.name} ");
        onTap?.call(_book);
      },
      onLongPress: () {
        onLongPress?.call(_book);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Row(
          children: [
            BookCover(_book),
            const Padding(padding: EdgeInsets.all(4)),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _book.name ?? "",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                if (_book.author?.isNotEmpty == true)
                  Text(
                    _book.author ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                Text(
                  _book.intro ?? "无",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (_book.latestChapterTitle?.isNotEmpty == true)
                  Text(
                    "最新: ${_book.latestChapterTitle}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                BookTag(_book),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
