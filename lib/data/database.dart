import 'package:shosai/utils/log.dart';
import 'package:sqflite/sqflite.dart';

/// 数据库迁移基础抽象
class Migration {
  int startVersion;
  int endVersion;
  Future<void> Function(Database database) migrate;

  Migration(this.startVersion, this.endVersion, {required this.migrate});
}

Future<void> updateTables(Database db, int oldVersion, int newVersion,
    List<Migration> migrations) async {
  List<Migration> needMigrations = migrations.where((element) {
    return element.startVersion >= oldVersion &&
        element.endVersion <= newVersion;
  }).toList();
  needMigrations.sort();
  for (Migration element in needMigrations) {
    await element.migrate(db);
  }
}

/// 表操作基础抽象
abstract class BaseTable<T> {
  Future<void> createTable(Database db) async {
    MyLog.d("BaseTable", "createTable: ${getTableName()}");
    await db.execute('CREATE TABLE ${getTableName()}${getColumnSql()}');
  }

  Future<void> dropTable(Database db) async {
    MyLog.d("BaseTable", "dropTable: ${getTableName()}");
    try {
      await db.execute("DROP TABLE ${getTableName()}");
    } catch (e) {
      MyLog.e("BaseTable", "dropTable error: $e");
    }
  }

  /// 表名
  String getTableName();

  /// 建表字段
  /// (id TEXT PRIMARY KEY, name TEXT, extension TEXT, local_path TEXT, charset TEXT)
  String getColumnSql();

  Future<int> insertOrUpdate(Database db, T value) async {
    MyLog.d("Table", "${getTableName()} insert: $value");
    return await db.insert(getTableName(), toMap(value),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Object?>> batchInsert(Database db, List<T> list) async {
    MyLog.d("Table", "${getTableName()} batchInsert: ${list.length}");
    Batch batch = db.batch();
    for (var element in list) {
      batch.insert(getTableName(), toMap(element),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    // List<Object?> result = await batch.commit();
    // for (var res in result) {
    //   MyLog.d("Table", "${getTableName()} result: ${res}");
    // }
    return await batch.commit();
  }

  Future<List<T>> query(Database db,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) async {
    final List<Map<String, dynamic>> maps = await db.query(getTableName(),
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
    return List.generate(maps.length, (index) {
      return fromMap(maps[index]);
    });
  }

  Future<int> delete(Database db,
      {String? where, List<Object?>? whereArgs}) async {
    return await db.delete(getTableName(), where: where, whereArgs: whereArgs);
  }

  Map<String, dynamic> toMap(T value);

  T fromMap(Map<String, dynamic> map);
}
