import 'package:flic_bluetooth_project/flic.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class flicDatabase {

  static final flicDatabase instance = flicDatabase._internal();

  flicDatabase._internal();
  late Future<Database> _database;

  Future<void> initDatabase() async {
    _database = _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flic_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE flic (
        uuid TEXT PRIMARY KEY,
        pushAction TEXT,
        doublePushAction TEXT,
        holdAction TEXT
      )
    ''');
  }

  Future<void> insertFlic(String uuid) async {
    final db = await _database;
    await db.insert(
      'flic', {
        'uuid': uuid,
        'pushAction': null,
        'doublePushAction': null,
        'holdAction': null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> updateFlicAction(String uuid, ClickType clickType, String action) async {
    final db = await _database;
    String column;
    switch (clickType) {
      case (ClickType.pushAction):
        column = 'pushAction';
        break;
      case ClickType.doublePushAction:
        column = 'doublePushAction';
        break;
      case ClickType.holdAction:
        column = 'holdAction';
        break;
    };

    await db.update(
      'flic',
      {
        column: action,
      },
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  Future<List<Map<String, Object?>>> loadItems() async {
    final db = await _database;
    return await db.query('flic');
  }
}