import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _tableName = "tasks";

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String _path = '${await getDatabasesPath()}tasks.db';
      // await deleteDatabase(_path); // Xóa cơ sở dữ liệu
      // String _path = await getDatabasesPath() + 'tasks.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          print("creating a new one");
          return db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title STRING, note TEXT, date STRING, "
            "startTime TEXT, endTime TEXT, "
            "remind INTEGER, repeat STRING, "
            "color INTEGER, "
            "isCompleted INTEGER)",
          );
        },

      );
    } catch (e) {
      print(e);
    }
  }

  static Future<int> insert(Task? task) async {
    print("insert function called");

    if (_db == null) {
      throw Exception("Database not initialized");
    }
    return await _db!.insert(_tableName, task!.toJson());

    // return await _db?.insert(_tableName, task!.toJson())??1;
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print("query function called");
    return await _db!.query(_tableName);
  }

  static delete (Task task) async{
   return await _db!.delete(_tableName, where: 'id=?', whereArgs: [task.id]);

  }

  static update(int id) async{
    return await _db!.rawUpdate('''
    UPDATE tasks
    SET isCompleted = ?
    WHERE id =?
    
    ''', [1, id]);
  }

  // // ✅ Hàm xóa toàn bộ task trong bảng
  // static Future<int> deleteAll() async {
  //   if (_db == null) throw Exception("Database not initialized");
  //   return await _db!.delete(_tableName);
  // }
  //
  // // ✅ Hàm reset lại giá trị tự tăng ID về 1
  // static Future<void> resetTaskId() async {
  //   if (_db == null) throw Exception("Database not initialized");
  //   await _db!.execute("DELETE FROM sqlite_sequence WHERE name = '$_tableName'");
  // }



// ham xoa tasks
  // static Future<void> dropTable() async {
  //   if (_db == null) return;
  //   await _db!.execute("DROP TABLE IF EXISTS $_tableName");
  // }

}
