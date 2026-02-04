import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/project.dart';
import '../models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 3;
  static const String _tableName = 'tasks';
  static const String _projectsTable = 'projects';

  static Future<void> initDb() async {
    if (_db != null) {
      debugPrint('db not null');
      return;
    }
    try {
      String path = '${await getDatabasesPath()}task.db';
      debugPrint('in db path');
      _db = await openDatabase(
        path,
        version: _version,
        onCreate: (Database db, int version) async {
          debugPrint('Creating new one');
          await _createTasksTable(db);
          await _createProjectsTable(db);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 2) {
            await _addColumnIfMissing(
              db,
              table: _tableName,
              column: 'project',
              type: 'STRING',
            );
            await _addColumnIfMissing(
              db,
              table: _tableName,
              column: 'isNote',
              type: 'INTEGER',
            );
          }
          if (oldVersion < 3) {
            await _createProjectsTable(db);
          }
        },
        onOpen: (Database db) async {
          await _createProjectsTable(db);
          await _addColumnIfMissing(
            db,
            table: _tableName,
            column: 'project',
            type: 'STRING',
          );
          await _addColumnIfMissing(
            db,
            table: _tableName,
            column: 'isNote',
            type: 'INTEGER',
          );
        },
      );
      print('DB Created');
    } catch (e) {
      print(e);
    }
  }

  static Future<void> _createTasksTable(Database db) async {
    await db.execute('CREATE TABLE $_tableName ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'title STRING, note TEXT, project STRING, isNote INTEGER, date STRING, '
        'startTime STRING, endTime STRING, '
        'remind INTEGER, repeat STRING, '
        'color INTEGER, '
        'isCompleted INTEGER)');
  }

  static Future<void> _createProjectsTable(Database db) async {
    await db.execute('CREATE TABLE IF NOT EXISTS $_projectsTable ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'name TEXT UNIQUE)');
  }

  static Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String type,
  }) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (e) {
      debugPrint('Column $column already exists: $e');
    }
  }

  static Future<int> insert(Task? task) async {
    print('insert function called');
    try {
      return await _db!.insert(_tableName, task!.toJson());
    } catch (e) {
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      return 9000;
    }
  }

  static Future<int> delete(Task task) async {
    print('insert');
    return await _db!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> deleteAll() async {
    print('insert');
    return await _db!.delete(_tableName);
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print('Query Called!!!!!!!!!!!!!!!!!!!');
    print('insert');
    return await _db!.query(_tableName);
  }

  static Future<int> update(int id) async {
    print('insert');
    return await _db!.rawUpdate('''
    UPDATE tasks
    SET isCompleted = ?
    WHERE id = ?
    ''', [1, id]);
  }

  static Future<int> updateTask(Task task) async {
    return await _db!.update(
      _tableName,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> insertProject(
    Project project, {
    bool ignoreDuplicate = false,
  }) async {
    return await _db!.insert(
      _projectsTable,
      project.toJson(),
      conflictAlgorithm:
          ignoreDuplicate ? ConflictAlgorithm.ignore : ConflictAlgorithm.abort,
    );
  }

  static Future<List<Map<String, dynamic>>> queryProjects() async {
    return await _db!.query(
      _projectsTable,
      orderBy: 'name ASC',
    );
  }

  static Future<int> updateProject(Project project) async {
    return await _db!.update(
      _projectsTable,
      project.toJson(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  static Future<int> deleteProject(Project project) async {
    return await _db!.delete(
      _projectsTable,
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  static Future<int> deleteTasksByProject(String projectName) async {
    return await _db!.delete(
      _tableName,
      where: 'project = ?',
      whereArgs: [projectName],
    );
  }

  static Future<int> updateProjectTasks(
    String oldName,
    String newName,
  ) async {
    return await _db!.update(
      _tableName,
      {'project': newName},
      where: 'project = ?',
      whereArgs: [oldName],
    );
  }
}
