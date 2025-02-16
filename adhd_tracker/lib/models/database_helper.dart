import 'package:adhd_tracker/models/goals.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('adhd_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';

    await db.execute('''
      CREATE TABLE goals (
        id $idType,
        name $textType,
        frequency $textType,
        startDate $textType,
        notes $textTypeNullable,
        createdAt $textType,
        updatedAt $textType
      )
    ''');
  }

  // Create
  Future<int> insertGoal(Goal goal) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    
    final Map<String, dynamic> data = goal.toMap()
      ..addAll({
        'createdAt': now,
        'updatedAt': now,
      });

    return await db.insert(
      'goals',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read
  Future<Goal?> getGoal(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'goals',
      columns: ['id', 'name', 'frequency', 'startDate', 'notes', 'createdAt', 'updatedAt'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Goal>> getAllGoals() async {
    final db = await instance.database;
    const orderBy = 'createdAt DESC';
    final result = await db.query('goals', orderBy: orderBy);
    
    return result.map((map) => Goal.fromMap(map)).toList();
  }

  // Update
  Future<int> updateGoal(Goal goal) async {
    final db = await instance.database;
    
    final Map<String, dynamic> data = goal.toMap()
      ..addAll({
        'updatedAt': DateTime.now().toIso8601String(),
      });

    return await db.update(
      'goals',
      data,
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // Delete
  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all goals
  Future<int> deleteAllGoals() async {
    final db = await instance.database;
    return await db.delete('goals');
  }

  // Additional utility methods
  Future<List<Goal>> searchGoals(String query) async {
    final db = await instance.database;
    
    final result = await db.query(
      'goals',
      where: 'name LIKE ? OR notes LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return result.map((map) => Goal.fromMap(map)).toList();
  }

  Future<bool> goalExists(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}