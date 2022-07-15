import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/dao/book_dao.dart';
import 'package:shosai/data/database.dart';
import 'package:shosai/utils/log.dart';
import 'package:sqflite/sqflite.dart';

/// 书籍相关数据库
class BookRepository {
  static const String _dbName = "book.db";
  Database? _database;
  final BookTable _bookTable = BookTable();
  final BookChapterTable _bookChapterTable = BookChapterTable();
  final BookSourceTable _bookSourceTable = BookSourceTable();
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
      version: 2,
    );
    return _database!;
  }

  Future<void> _createTables(Database db) async {
    await _bookTable.createTable(db);
    await _bookChapterTable.createTable(db);
    await _bookSourceTable.createTable(db);
  }

  Future<void> _dropTables(Database db) async {
    await _bookTable.dropTable(db);
    await _bookChapterTable.dropTable(db);
    await _bookSourceTable.dropTable(db);
  }

  // --------------------------------------------------
  // --------------------------------------------------

  /// 新增或更新书籍信息
  Future<int> insertOrUpdateBook(Book book) async {
    return _bookTable.insertOrUpdate(await _openDb(), book);
  }

  /// 删除书籍
  Future<int> deleteBook(Book book) async {
    await clearBookChapters(book.id);
    return _bookTable
        .delete(await _openDb(), where: "id = ?", whereArgs: [book.id]);
  }

  /// 查询所有书籍
  Future<List<Book>> queryAllBooks() async {
    return _bookTable.query(await _openDb(), orderBy: 'latestVisitTime DESC');
  }

  // --------------------------------------------------
  /// 插入或更新章节信息
  Future<List<Object?>> insertChapters(List<BookChapter> chapters) async {
    return _bookChapterTable.batchInsert(await _openDb(), chapters);
  }

  /// 查询指定书籍的章节信息
  Future<List<BookChapter>> queryBookChapters(String bookId) async {
    return _bookChapterTable.query(await _openDb(),
        where: 'bookId = ?', whereArgs: [bookId]);
  }

  /// 清除指定书籍的章节信息
  Future<int> clearBookChapters(String bookId) async {
    return _bookChapterTable.delete(await _openDb(),
        where: 'bookId = ?', whereArgs: [bookId]);
  }

  // --------------------------------------------------

  Future<int> updateBookSource(BookSource source) async {
    return _bookSourceTable.insertOrUpdate(await _openDb(), source);
  }

  Future<List<Object?>> insertBookSources(List<BookSource> sources) async {
    return _bookSourceTable.batchInsert(await _openDb(), sources);
  }

  Future<BookSource?> queryBookSource(String url) async {
    List<BookSource> list = await _bookSourceTable
        .query(await _openDb(), where: 'url = ?', whereArgs: [url]);
    if (list.isEmpty) {
      return null;
    } else {
      return list[0];
    }
  }

  /// 获取所有书源列表
  Future<List<BookSource>> queryAllBookSources() async {
    return _bookSourceTable.query(await _openDb(),
        orderBy: 'lastUpdateTime DESC');
  }
}
