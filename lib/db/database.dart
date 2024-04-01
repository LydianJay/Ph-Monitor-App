import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHelper {
  static Database? db;

  static Future<Database> initDatabase() async {
    var databasesPath = await getDatabasesPath();

    String path = join(databasesPath, 'phrecords.db');
    db = await openDatabase(path);
    await _initTables();
    return db!;
  }

  static Future<void> _initTables() async {
    await _createTables();
  }

  static Future<void> _createTables() async {
    debugPrint('Creating tables...');
    //await db!.execute('DROP TABLE IF EXISTS records');
    await db!.execute('''
      CREATE TABLE IF NOT EXISTS records (
        id INTEGER PRIMARY KEY,
        ph REAL,
        date TEXT
      );  
      ''');
  }
}
