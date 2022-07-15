import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';

/// 书籍封面
class BookCover extends StatelessWidget {
  Book book;

  BookCover(this.book, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: sqrt1_2, // A4 比例 sqrt1_2
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        // shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.all(Radius.circular(4))),
        child: loadImage(book),
      ),
    );
  }

  loadImage(Book book) {
    String? url = book.coverUrl;
    if (url == null) {
      return Center(
        child: Text(
          book.name ?? "",
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      );
    }
    return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
        errorWidget: (context, url, error) => const Icon(Icons.error));
  }
}

/// 标签
class BookTag extends StatelessWidget {
  Book book;

  BookTag(this.book, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? tags = book.tags;
    Color color = Colors.blue.shade400;
    if (tags == null || tags.isEmpty) {
      return Text("");
    } else {
      return Container(
        decoration: BoxDecoration(
          // color: Colors.black12,
          border:
              Border.all(color: color, width: 1.0, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(2),
        ),
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Text(
          tags,
          strutStyle: StrutStyle(
            forceStrutHeight:
                true, // 去除了文字的内边距，同android的 includeFontPadding = false
          ),
          style: TextStyle(fontSize: 12, color: color),
        ),
      );
    }
  }
}
