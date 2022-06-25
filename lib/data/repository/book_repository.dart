import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/database.dart';
import 'package:shosai/utils/log.dart';
import 'package:sqflite/sqflite.dart';

/// 书籍相关数据库
class BookRepository {
  static const String _dbName = "book.db";
  Database? _database;
  final BookTable _bookTable = BookTable();
  final BookChapterTable _bookChapterTable = BookChapterTable();
  late List<Migration> migrations = [
    // Migration(3, 4, migrate: (db) {
    //   return db.execute(
    //       "ALTER TABLE ${_bookTable.getTableName()} ADD latestVisitTime INTEGER");
    // }),
  ];

  Future<Database> _openDb() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (_database?.isOpen == true) {
      // MyLog.d("BookRepository", "${_database?.path} isOpened");
      return _database!;
    }
    String path = join(await getDatabasesPath(), _dbName);
    // MyLog.d("BookRepository", "openDatabase: $path");
    _database = await openDatabase(
      path,
      onCreate: (db, version) {
        // MyLog.d("BookRepository", "onCreate: $version");
        return _createTables(db);
      },
      // onOpen: (db) {
      //   MyLog.d("BookRepository", "onOpen ${db.path}");
      // },
      // onConfigure: (db) {
      //   MyLog.d("BookRepository", "onConfigure ${db.path}");
      // },
      onUpgrade: (db, oldVersion, newVersion) async {
        MyLog.d("BookRepository",
            "onUpgrade: ${db.path} ---- $oldVersion >> $newVersion");
        // onDatabaseDowngradeDelete(db, oldVersion, newVersion);
        await _dropTables(db);
        await _createTables(db);
        await updateTables(db, oldVersion, newVersion, migrations);
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        MyLog.d("BookRepository",
            "onDowngrade: ${db.path} ---- $oldVersion >> $newVersion");
        // onDatabaseDowngradeDelete(db, oldVersion, newVersion);
        await _dropTables(db);
        await _createTables(db);
      },
      version: 4,
    );
    return _database!;
  }

  Future<void> _createTables(Database db) async {
    await _bookTable.createTable(db);
    await _bookChapterTable.createTable(db);
  }

  Future<void> _dropTables(Database db) async {
    await _bookTable.dropTable(db);
    await _bookChapterTable.dropTable(db);
  }

  // --------------------------------------------------

  Future<int> insertOrUpdateBook(Book book) async {
    return _bookTable.insertOrUpdate(await _openDb(), book);
  }

  Future<int> deleteBook(Book book) async {
    await clearBookChapters(book.id);
    return _bookTable
        .delete(await _openDb(), where: "id = ?", whereArgs: [book.id]);
  }

  Future<List<Book>> queryAllBooks() async {
    return _bookTable.queryAll(await _openDb(),
        orderBy: 'latestVisitTime desc');
  }

  Future<List<Object?>> insertChapters(List<BookChapter> chapters) async {
    return _bookChapterTable.batchInsert(await _openDb(), chapters);
  }

  Future<List<BookChapter>> queryBookChapters(String bookId) async {
    return _bookChapterTable
        .queryAll(await _openDb(), where: 'bookId = ?', whereArgs: [bookId]);
  }

  Future<int> clearBookChapters(String bookId) async {
    return _bookChapterTable
        .delete(await _openDb(), where: 'bookId = ?', whereArgs: [bookId]);
  }
}

/// 书籍表
class BookTable extends BaseTable<Book> {
  @override
  String getTableName() {
    return "books";
  }

  @override
  String getColumnSql() {
    return "(id TEXT PRIMARY KEY, name TEXT, extension TEXT, localPath TEXT, charset TEXT, latestVisitTime INTEGER, importTime INTEGER)";
  }

  @override
  Book fromMap(Map<String, dynamic> map) {
    Book book = Book(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      extension: map['extension'] ?? ".txt",
      localPath: map['localPath'] ?? "",
    );
    book.charset = map['charset'];
    book.latestVisitTime = map['latestVisitTime'] ?? 0;
    book.importTime = map['importTime'] ?? 0;
    return book;
  }

  @override
  Map<String, dynamic> toMap(Book value) {
    return {
      'id': value.id,
      'name': value.name,
      'extension': value.extension,
      'localPath': value.localPath,
      'charset': value.charset,
      'latestVisitTime': value.latestVisitTime,
      'importTime': value.importTime,
    };
  }
}

/// 章节表
class BookChapterTable extends BaseTable<BookChapter> {
  @override
  String getColumnSql() {
    return "(id TEXT PRIMARY KEY, bookId TEXT, _index INTEGER, title TEXT, charStart INTEGER, charEnd INTEGER)";
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
