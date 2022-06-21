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
    //       "ALTER TABLE ${_bookTable.getTableName()} ADD latest_visit_time INTEGER");
    // }),
  ];

  Future<Database> _openDb() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (_database?.isOpen == true) {
      MyLog.d("BookRepository", "${_database?.path} isOpened");
      return _database!;
    }
    String path = join(await getDatabasesPath(), _dbName);
    MyLog.d("BookRepository", "openDatabase: $path");
    _database = await openDatabase(
      path,
      onCreate: (db, version) {
        MyLog.d("BookRepository", "onCreate: $version");
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

  Future<void> insertOrUpdateBook(Book book) async {
    await _bookTable.insertOrUpdate(await _openDb(), book);
  }

  Future<List<Book>> queryAllBooks() async {
    return await _bookTable.queryAll(await _openDb(),
        orderBy: 'latest_visit_time desc');
  }

  Future<void> insertChapters(List<BookChapter> chapters) async {
    await _bookChapterTable.batchInsert(await _openDb(), chapters);
  }

  Future<List<BookChapter>> queryBookChapters(String bookId) async {
    return await _bookChapterTable
        .queryAll(await _openDb(), where: 'bookId = ?', whereArgs: [bookId]);
  }

  Future<int> clearBookChapters(String bookId) async {
    return await _bookChapterTable
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
    return "(id TEXT PRIMARY KEY, name TEXT, extension TEXT, local_path TEXT, charset TEXT, latest_visit_time INTEGER)";
  }

  @override
  Book fromMap(Map<String, dynamic> map) {
    Book book = Book(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      extension: map['extension'] ?? ".txt",
      localPath: map['local_path'] ?? "",
    );
    book.charset = map['charset'];
    return book;
  }

  @override
  Map<String, dynamic> toMap(Book value) {
    return {
      'id': value.id,
      'name': value.name,
      'extension': value.extension,
      'local_path': value.localPath,
      'charset': value.charset,
      'latest_visit_time': value.latestVisitTime,
    };
  }
}

/// 章节表
class BookChapterTable extends BaseTable<BookChapter> {
  @override
  String getColumnSql() {
    return "(id TEXT PRIMARY KEY, bookId TEXT, _index INTEGER, title TEXT, char_start INTEGER, char_end INTEGER)";
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
      charStart: map['char_start'] ?? 0,
      charEnd: map['char_end'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap(BookChapter value) {
    return {
      'id': "${value.bookId}_${value.title}_${value.index}",
      'bookId': value.bookId,
      '_index': value.index,
      'title': value.title,
      'char_start': value.charStart,
      'char_end': value.charEnd
    };
  }
}
