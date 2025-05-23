import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'heartsync.db');
    return await openDatabase(
      path,
      version: 2, // Incrementar a versão de 1 para 2
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            email TEXT UNIQUE,
            dataNascimento TEXT,
            senha TEXT,
            temFoto INTEGER,
            profileImagePath TEXT,
            anniversaryDate TEXT,
            syncDate TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS uso_celular (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idUsuario INTEGER,
            dataUso TEXT,
            tempoUsadoEmMinutos INTEGER,
            metaUso INTEGER,
            FOREIGN KEY (idUsuario) REFERENCES usuarios(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS recados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idUsuario INTEGER,
            texto TEXT,
            dataHora TEXT,
            isOther INTEGER,
            FOREIGN KEY (idUsuario) REFERENCES usuarios(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS roleta (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idUsuario INTEGER,
            dataRoleta TEXT,
            atividade TEXT,
            proximaRoleta TEXT,
            FOREIGN KEY (idUsuario) REFERENCES usuarios(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Criar uma nova tabela sem a coluna heartcode
          await db.execute('''
            CREATE TABLE usuarios_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT,
              email TEXT UNIQUE,
              dataNascimento TEXT,
              senha TEXT,
              temFoto INTEGER,
              profileImagePath TEXT,
              anniversaryDate TEXT,
              syncDate TEXT
            )
          ''');
          // Copiar os dados da tabela antiga para a nova, ignorando heartcode
          await db.execute('''
            INSERT INTO usuarios_new (id, nome, email, dataNascimento, senha, temFoto, profileImagePath, anniversaryDate, syncDate)
            SELECT id, nome, email, dataNascimento, senha, temFoto, profileImagePath, anniversaryDate, syncDate
            FROM usuarios
          ''');
          // Deletar a tabela antiga
          await db.execute('DROP TABLE usuarios');
          // Renomear a nova tabela
          await db.execute('ALTER TABLE usuarios_new RENAME TO usuarios');
        }
      },
    );
  }

  Future<DatabaseHelper> init() async {
    await database;
    return this;
  }

  Future<int> insertUsuario({
    required String nome,
    required String email,
    required String dataNascimento,
    required String senha,
    required bool temFoto,
    String? profileImagePath,
    String? anniversaryDate,
    String? syncDate,
  }) async {
    final db = await database;
    return await db.insert('usuarios', {
      'nome': nome,
      'email': email,
      'dataNascimento': dataNascimento,
      'senha': senha,
      'temFoto': temFoto ? 1 : 0,
      'profileImagePath': profileImagePath,
      'anniversaryDate': anniversaryDate,
      'syncDate': syncDate,
    });
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final db = await database;
    return await db.query('usuarios');
  }

  Future<List<Map<String, dynamic>>> getUsoCelularUltimaSemana(int userId) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: 6)).toIso8601String().split('T')[0];
    return await db.query(
      'uso_celular',
      where: 'idUsuario = ? AND dataUso >= ?',
      whereArgs: [userId, startDate],
    );
  }

  Future<Map<String, dynamic>> getTempoRestante(int userId, String dataUso) async {
    final db = await database;
    final result = await db.query(
      'uso_celular',
      where: 'idUsuario = ? AND dataUso = ?',
      whereArgs: [userId, dataUso],
      limit: 1,
    );
    if (result.isNotEmpty) {
      final tempoUsado = result.first['tempoUsadoEmMinutos'] as int;
      final metaUso = result.first['metaUso'] as int;
      return {
        'tempoUsado': tempoUsado,
        'metaUso': metaUso,
        'tempoRestante': metaUso - tempoUsado,
      };
    }
    return {'tempoUsado': 0, 'metaUso': 240, 'tempoRestante': 240};
  }

  Future<double> getMediaSemanal(int userId) async {
    final usoSemanal = await getUsoCelularUltimaSemana(userId);
    if (usoSemanal.isEmpty) return 0.0;
    final total = usoSemanal.fold<int>(0, (sum, item) => sum + (item['tempoUsadoEmMinutos'] as int));
    return total / usoSemanal.length;
  }

  Future<void> insertUsoCelular({
    required int idUsuario,
    required String dataUso,
    required int tempoUsadoEmMinutos,
    required int metaUso,
  }) async {
    final db = await database;
    await db.insert('uso_celular', {
      'idUsuario': idUsuario,
      'dataUso': dataUso,
      'tempoUsadoEmMinutos': tempoUsadoEmMinutos,
      'metaUso': metaUso,
    });
  }

  Future<int> getStreakCount(int userId) async {
    final usoSemanal = await getUsoCelularUltimaSemana(userId);
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i)).toIso8601String().split('T')[0];
      final hasData = usoSemanal.any((u) => u['dataUso'] == date);
      if (hasData) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<List<Map<String, dynamic>>> getRecados(int userId) async {
    final db = await database;
    return await db.query(
      'recados',
      where: 'idUsuario = ?',
      whereArgs: [userId],
      orderBy: 'dataHora DESC',
    );
  }

  Future<void> insertRecado({
    required int idUsuario,
    required String texto,
    required String dataHora,
    required bool isOther,
  }) async {
    final db = await database;
    await db.insert('recados', {
      'idUsuario': idUsuario,
      'texto': texto,
      'dataHora': dataHora,
      'isOther': isOther ? 1 : 0,
    });
  }

  Future<Map<String, dynamic>?> getLatestRoulette(int userId) async {
    final db = await database;
    final result = await db.query(
      'roleta',
      where: 'idUsuario = ?',
      whereArgs: [userId],
      orderBy: 'dataRoleta DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertRoulette({
    required int idUsuario,
    required String dataRoleta,
    required String atividade,
    required String proximaRoleta,
  }) async {
    final db = await database;
    await db.insert('roleta', {
      'idUsuario': idUsuario,
      'dataRoleta': dataRoleta,
      'atividade': atividade,
      'proximaRoleta': proximaRoleta,
    });
  }
}