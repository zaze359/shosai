import 'package:shosai/utils/log.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<int> insert(Database db, T value) async {
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

  Future<List<T>> queryAll(Database db, {String? where}) async {
    final List<Map<String, dynamic>> maps;
    if (where != null && where.isNotEmpty) {
      maps = await db.query("${getTableName()} $where");
    } else {
      maps = await db.query(getTableName());
    }
    return List.generate(maps.length, (index) {
      return fromMap(maps[index]);
    });
  }

  Map<String, dynamic> toMap(T value);

  T fromMap(Map<String, dynamic> map);
}
