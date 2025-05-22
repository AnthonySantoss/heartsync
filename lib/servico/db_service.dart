
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('heartsync.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE example(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    )
    ''');
  }

  Future<void> insertExample(String name) async {
    final db = await database;
    await db.insert('example', {'name': name});
  }

  Future<List<Map<String, dynamic>>> fetchExamples() async {
    final db = await database;
    return await db.query('example');
  }
}
