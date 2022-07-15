import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/database.dart';

/// 书籍表
class BookTable extends BaseTable<Book> {
  @override
  String getTableName() {
    return "books";
  }

  @override
  String getColumnSql() {
    return "(id TEXT PRIMARY KEY, "
        "name TEXT, "
        "extension TEXT, "
        "localPath TEXT, "
        "origin TEXT, "
        "charset TEXT, "
        "intro TEXT, "
        "latestVisitTime INTEGER, "
        "importTime INTEGER, "
        "author TEXT, "
        "tags TEXT, "
        "wordCount TEXT, "
        "updateTime TEXT, "
        "latestChapterTitle TEXT, "
        "latestCheckTime INTEGER, "
        "coverUrl TEXT,"
        "tocUrl TEXT"
        ")";
  }

  @override
  Book fromMap(Map<String, dynamic> map) {
    return Book.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(Book value) {
    return value.toMap();
  }
}

/// 章节表
class BookChapterTable extends BaseTable<BookChapter> {
  @override
  String getColumnSql() {
    return "(id TEXT PRIMARY KEY, "
        "bookId TEXT, "
        "_index INTEGER, "
        "title TEXT, "
        "charStart INTEGER, "
        "charEnd INTEGER)";
  }

  @override
  String getTableName() {
    return "book_chapter";
  }

  @override
  BookChapter fromMap(Map<String, dynamic> map) {
    return BookChapter(
      bookId: map['bookId'] ?? "",
      index: map['_index'] ?? 0,
      title: map['title'] ?? "",
      charStart: map['charStart'] ?? 0,
      charEnd: map['charEnd'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap(BookChapter value) {
    return {
      'id': "${value.bookId}_${value.title}_${value.index}",
      'bookId': value.bookId,
      '_index': value.index,
      'title': value.title,
      'charStart': value.charStart,
      'charEnd': value.charEnd
    };
  }
}

/// 书源表
class BookSourceTable extends BaseTable<BookSource> {
  @override
  BookSource fromMap(Map<String, dynamic> map) {
    return BookSource.fromMap(map);
  }

  @override
  String getColumnSql() {
    return "(url TEXT PRIMARY KEY, "
        "name TEXT, "
        "tags TEXT, "
        "comment TEXT, "
        "searchUrl TEXT, "
        "searchRule TEXT, "
        "tocRule TEXT, "
        "bookInfoRule TEXT, "
        "lastUpdateTime INTEGER)";
  }

  @override
  String getTableName() {
    return "book_source";
  }

  @override
  Map<String, dynamic> toMap(BookSource value) {
    return value.toMap();
  }
}
