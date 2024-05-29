import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._inst(); //singleton
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._inst();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'students_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }
  

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        place TEXT,
       
        contact INTEGER,
        imagePath TEXT
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    var result = await db.insert('students_table', row);
    return result;
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'students_table',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'students_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> searchAll(String searchQuery) async {
    final db = await database;
    if (searchQuery.isEmpty) {
      return await db.query('students_table');
    } else {
      return await db.query(
        'students_table',
        where: 'name LIKE ?',
        whereArgs: ['%$searchQuery%'],
      );
    }
  }
}