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
CREATE TABLE couple (
id INTEGER PRIMARY KEY AUTOINCREMENT,
userName1 TEXT,
heartCode1 TEXT,
birthDate1 TEXT,
userName2 TEXT,
heartCode2 TEXT,
birthDate2 TEXT,
anniversaryDate TEXT,
syncDate TEXT,
imageUrl1 TEXT,
imageUrl2 TEXT
)
''');
  }

  Future<void> saveCoupleProfile(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('couple', {
      'userName1': data['user1']['nome'],
      'heartCode1': data['user1']['heartcode'],
      'birthDate1': data['user1']['dataNascimento'],
      'userName2': data['user2']['nome'],
      'heartCode2': data['user2']['heartcode'],
      'birthDate2': data['user2']['dataNascimento'],
      'anniversaryDate': data['couple']['anniversaryDate'],
      'syncDate': data['couple']['syncDate'],
      'imageUrl1': data['user1']['profileImagePath'],
      'imageUrl2': data['user2']['profileImagePath'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getCachedCoupleProfile() async {
    final db = await database;
    final result = await db.query('couple', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}