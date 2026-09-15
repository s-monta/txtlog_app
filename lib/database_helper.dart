import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'models/log_entry.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'text_logs.db';
  static const _databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final databasePath = path.join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE logs ADD COLUMN updated_at TEXT');
        }
      },
    );
  }

  Future<int> insertLog(String content) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.insert('logs', {
      'content': content,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<List<LogEntry>> getAllLogs() async {
    final db = await database;
    final rows = await db.query('logs', orderBy: 'id DESC');
    return rows.map(LogEntry.fromMap).toList();
  }

  Future<int> updateLog(int id, String content) async {
    final db = await database;
    return db.update(
      'logs',
      {
        'content': content,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLog(int id) async {
    final db = await database;
    return db.delete('logs', where: 'id = ?', whereArgs: [id]);
  }
}
