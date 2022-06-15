import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/sqlite_base.dart';
import 'package:shosai/utils/log.dart';
import 'package:sqflite/sqflite.dart';

/// 书籍相关数据库
class BookRepository {
  static const String _dbName = "book.db";
  Database? _database;
  final BookTable _bookTable = BookTable();
  final BookChapterTable _bookChapterTable = BookChapterTable();

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
        // TODO 数据迁移
        MyLog.d("BookRepository",
            "onUpgrade: ${db.path} ---- $oldVersion >> $newVersion");
        // onDatabaseDowngradeDelete(db, oldVersion, newVersion);
        await _dropTables(db);
        await _createTables(db);
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        MyLog.d("BookRepository",
            "onDowngrade: ${db.path} ---- $oldVersion >> $newVersion");
        // onDatabaseDowngradeDelete(db, oldVersion, newVersion);
        await _dropTables(db);
        await _createTables(db);
      },
      version: 3,
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

  Future<void> insertBook(Book book) async {
    await _bookTable.insert(await _openDb(), book);
  }

  Future<List<Book>> queryAllBooks() async {
    return _bookTable.queryAll(await _openDb());
  }

  Future<void> insertChapters(List<BookChapter> chapters) async {
    await _bookChapterTable.batchInsert(await _openDb(), chapters);
  }

  Future<List<BookChapter>> queryBookChapters(String bookId) async {
    return _bookChapterTable.queryAll(await _openDb(), where: "WHERE bookId='$bookId'");
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
    return "(id TEXT PRIMARY KEY, name TEXT, extension TEXT, local_path TEXT, charset TEXT)";
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
