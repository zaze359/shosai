import 'dart:convert';

import 'package:shosai/core/database/model/book_entity.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/core/database/database.dart';
import 'package:sqflite/sqflite.dart';


class BookDao {
  final BookTable _bookTable = BookTable();
  final BookChapterTable _bookChapterTable = BookChapterTable();
  final BookSourceTable _bookSourceTable = BookSourceTable();

  Future<void> createTables(Database db) async {
    await _bookTable.createTable(db);
    await _bookChapterTable.createTable(db);
    await _bookSourceTable.createTable(db);
  }

  Future<void> dropTables(Database db) async {
    await _bookTable.dropTable(db);
    await _bookChapterTable.dropTable(db);
    await _bookSourceTable.dropTable(db);
  }


  /// 新增或更新书籍信息
  Future<int> insertOrUpdateBook(BookEntity book) async {
    return _bookTable.insertOrUpdate(await getDatabase(), book);
  }

  /// 删除书籍
  Future<int> deleteBook(String bookId) async {
    return _bookTable
        .delete(await getDatabase(), where: "id = ?", whereArgs: [bookId]);
  }

  /// 删除书籍
  Future<List<BookEntity>> queryBook(String bookId) async {
    return _bookTable
        .query(await getDatabase(), where: "id = ?", whereArgs: [bookId]);
  }

  /// 查询所有书籍
  Future<List<BookEntity>> queryAllBooks() async {
    return _bookTable.query(
        await getDatabase(), orderBy: 'latestVisitTime DESC');
  }

  // --------------------------------------------------
  /// 新增或更新章节信息
  Future<int> insertOrUpdateChapter(BookChapterEntity chapter) async {
    return _bookChapterTable.insertOrUpdate(await getDatabase(), chapter);
  }

  /// 插入或更新章节信息
  Future<List<Object?>> insertChapters(List<BookChapterEntity> chapters) async {
    return _bookChapterTable.batchInsert(await getDatabase(), chapters);
  }

  /// 查询指定书籍的章节信息
  Future<List<BookChapterEntity>> queryBookChapters(String bookId) async {
    return _bookChapterTable
        .query(await getDatabase(), where: 'bookId = ?', whereArgs: [bookId]);
  }

  /// 清除指定书籍的章节信息
  Future<int> clearBookChapters(String bookId) async {
    return _bookChapterTable
        .delete(await getDatabase(), where: 'bookId = ?', whereArgs: [bookId]);
  }

  // --------------------------------------------------

  Future<int> updateBookSource(BookSource source) async {
    return _bookSourceTable.insertOrUpdate(await getDatabase(), source);
  }

  Future<List<Object?>> insertBookSources(List<BookSource> sources) async {
    return _bookSourceTable.batchInsert(await getDatabase(), sources);
  }

  Future<BookSource?> queryBookSource(String url) async {
    List<BookSource> list = await _bookSourceTable
        .query(await getDatabase(), where: 'url = ?', whereArgs: [url]);
    if (list.isEmpty) {
      return null;
    } else {
      return list[0];
    }
  }

  /// 获取所有书源列表
  Future<List<BookSource>> queryAllBookSources() async {
    return _bookSourceTable.query(
        await getDatabase(), orderBy: 'errorFlag ASC, lastUpdateTime DESC');
  }

}


/// 书籍表
class BookTable extends BaseTable<BookEntity> {
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
  BookEntity fromMap(Map<String, dynamic> map) {
    return BookEntity(map['id'])
      ..name = map['name']
      ..extension = map['extension']
      ..localPath = map['localPath']
      ..origin = map['origin'] ?? ""
      ..charset = map['charset']
      ..intro = map['intro']
      ..latestVisitTime = map['latestVisitTime'] ?? 0
      ..importTime = map['importTime'] ?? 0
      ..author = map['author']
      ..tags = map['tags']
      ..wordCount = map['wordCount']
      ..updateTime = map['updateTime']
      ..latestChapterTitle = map['latestChapterTitle']
      ..latestCheckTime = map['latestCheckTime'] ?? 0
      ..coverUrl = map['coverUrl']
      ..tocUrl = map['tocUrl'];
  }

  @override
  Map<String, dynamic> toMap(BookEntity value) {
    return {
      'id': value.id,
      'name': value.name,
      'extension': value.extension,
      'origin': value.origin,
      'localPath': value.localPath,
      'charset': value.charset,
      'intro': value.intro,
      'latestVisitTime': value.latestVisitTime,
      'importTime': value.importTime,
      'author': value.author,
      'tags': value.tags,
      'wordCount': value.wordCount,
      'updateTime': value.updateTime,
      'latestChapterTitle': value.latestChapterTitle,
      'latestCheckTime': value.latestCheckTime,
      'coverUrl': value.coverUrl,
      'tocUrl': value.tocUrl,
    };
  }
}

/// 章节表
class BookChapterTable extends BaseTable<BookChapterEntity> {
  @override
  String getColumnSql() {
    return "(id TEXT PRIMARY KEY, "
        "bookId TEXT, "
        "url TEXT, "
        "localPath TEXT, "
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
  BookChapterEntity fromMap(Map<String, dynamic> map) {
    return BookChapterEntity(
      bookId: map['bookId'] ?? "",
      index: map['_index'] ?? 0,
      url: map['url'] ?? "",
      title: map['title'] ?? "",
      charStart: map['charStart'] ?? 0,
      charEnd: map['charEnd'] ?? 0,
      localPath: map['localPath'],
    );
  }

  @override
  Map<String, dynamic> toMap(BookChapterEntity value) {
    return {
      'id': "${value.bookId}_${value.index}",
      'bookId': value.bookId,
      '_index': value.index,
      'title': value.title,
      'charStart': value.charStart,
      'charEnd': value.charEnd,
      'url': value.url,
      'localPath': value.localPath,
    };
  }
}

/// 书源表
class BookSourceTable extends BaseTable<BookSource> {

  @override
  String getColumnSql() {
    return "(url TEXT PRIMARY KEY, "
        "name TEXT, "
        "tags TEXT, "
        "comment TEXT, "
        "errorFlag INTEGER, "
        "searchUrl TEXT, "
        "searchRule TEXT, "
        "tocRule TEXT, "
        "bookInfoRule TEXT, "
        "contentRule TEXT, "
        "lastUpdateTime INTEGER)";
  }

  @override
  String getTableName() {
    return "book_source";
  }

  @override
  Map<String, dynamic> toMap(BookSource value) {
    return {
      'url': value.url,
      'name': value.name,
      'tags': value.tags,
      'comment': value.comment,
      'errorFlag': value.errorFlag,
      'searchUrl': jsonEncode(value.searchUrl),
      'searchRule': jsonEncode(value.searchRule),
      'tocRule': jsonEncode(value.tocRule),
      'bookInfoRule': jsonEncode(value.bookInfoRule),
      'contentRule': jsonEncode(value.contentRule),
      'lastUpdateTime': value.lastUpdateTime,
    };
  }

  @override
  BookSource fromMap(Map<String, dynamic> map) {
    return BookSource(
      url: map['url'],
      name: map['name'],
    )
      ..tags = map['tags']
      ..comment = map['comment']
      ..errorFlag = map['errorFlag'] ?? 0
      ..searchUrl = BookUrl.fromJson(jsonDecode(map['searchUrl'] ?? "{}"))
      ..searchRule =
      SearchRule.fromJson(jsonDecode(map['searchRule'] ?? "{}"))
      ..tocRule = TocRule.fromJson(jsonDecode(map['tocRule'] ?? "{}"))
      ..bookInfoRule =
      BookInfoRule.fromJson(jsonDecode(map['bookInfoRule'] ?? "{}"))
      ..contentRule =
      ContentRule.fromJson(jsonDecode(map['contentRule'] ?? "{}"))
      ..lastUpdateTime = map['lastUpdateTime'] ?? 0;
  }
}
