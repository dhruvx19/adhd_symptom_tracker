// models/database_helper.dart
import 'package:mindle/models/reminder_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        frequency TEXT NOT NULL,
        startDate TEXT NOT NULL,
        notes TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        scheduledTime TEXT NOT NULL,
        sound TEXT
      )
    ''');
  }

  Future<int> insertReminder(Reminder reminder) async {
    final db = await instance.database;
    return await db.insert('reminder', reminder.toMap());
  }

  Future<List<Reminder>> getAllReminder() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('reminder');
    return List.generate(maps.length, (i) => Reminder.fromMap(maps[i]));
  }

  Future<int> updateReminderCompletion(int id, bool isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'reminder',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await instance.database;
    return await db.delete(
      'reminder',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}