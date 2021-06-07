import 'dart:io';

import 'package:todo_app/models/task_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;
  DatabaseHelper._instance();
  String taskTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_task.db';
    final todoTaskDb =
        await openDatabase(path, version: 1, onCreate: _onCreateDb);
    return todoTaskDb;
  }

  void _onCreateDb(Database db, int version) async {
    db.execute(
        'CREATE TABLE $taskTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDate TEXT,$colPriority TEXT, $colStatus INTEGER)');
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> res = await db.query(taskTable);

    return res;
  }

  Future<List<Map<String, dynamic>>> getTaskMapListByDate(String date) async {
    Database db = await this.db;
    final List<Map<String, dynamic>> res =
        await db.query(taskTable, where: '$colDate =?', whereArgs: [date]);
    return res;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    return taskList;
  }

  Future<List<Task>> getTaskListByDate(String date) async {
    final List<Map<String, dynamic>> taskMapList =
        await getTaskMapListByDate(date);
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    return taskList;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    print("data insertion started");
    final int result = await db.insert(taskTable, task.toMap());
    print("data inserted $result");
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    print('${task.title},${task.id},${task.date},${task.priority}');

    final int result = await db.update(taskTable, task.toMap(),
        where: '$colId =?', whereArgs: [task.id]);
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result =
        await db.delete(taskTable, where: '$colId =?', whereArgs: [id]);
  }
}
