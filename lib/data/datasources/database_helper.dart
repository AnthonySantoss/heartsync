import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('heartsync.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        dataNascimento TEXT,
        senha TEXT NOT NULL,
        temFoto INTEGER NOT NULL CHECK (temFoto IN (0,1)),
        profileImagePath TEXT,
        heartcode TEXT NOT NULL UNIQUE CHECK (length(heartcode) >= 7 AND length(heartcode) <= 11),
        conectado INTEGER NOT NULL CHECK (conectado IN (0,1))
      )
    ''');

    await db.execute('''
      CREATE TABLE casais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuario1 INTEGER NOT NULL,
        idUsuario2 INTEGER NOT NULL,
        codigoConexao TEXT NOT NULL UNIQUE,
        FOREIGN KEY (idUsuario1) REFERENCES usuarios(id),
        FOREIGN KEY (idUsuario2) REFERENCES usuarios(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE momentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCasal INTEGER NOT NULL,
        tituloMomento TEXT NOT NULL,
        descricao TEXT,
        dataMomento TEXT,
        foiRealizado INTEGER NOT NULL CHECK (foiRealizado IN (0,1)),
        FOREIGN KEY (idCasal) REFERENCES casais(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE uso_celular (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuario INTEGER NOT NULL,
        dataUso TEXT,
        tempoUsadoEmMinutos INTEGER,
        metaUso INTEGER,
        FOREIGN KEY (idUsuario) REFERENCES usuarios(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE usuarios ADD COLUMN profileImagePath TEXT');
    }
  }

  // Função para hash da senha
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Inserir usuário com transação
  Future<int> insertUsuario({
    required String nome,
    required String email,
    required String dataNascimento,
    required String senha,
    required bool temFoto,
    String? profileImagePath,
    required String heartcode,
    required bool conectado,
  }) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.insert('usuarios', {
        'nome': nome,
        'email': email,
        'dataNascimento': dataNascimento,
        'senha': _hashPassword(senha), // Aplica hash na senha
        'temFoto': temFoto ? 1 : 0,
        'profileImagePath': profileImagePath,
        'heartcode': heartcode,
        'conectado': conectado ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.rollback);
    });
  }

  // Buscar todos os usuários
  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final db = await database;
    return await db.query('usuarios', orderBy: 'id DESC');
  }

  // Verificar se o email já existe
  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Verificar se o heartcode já existe
  Future<bool> heartCodeExists(String heartcode) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'heartcode = ?',
      whereArgs: [heartcode],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Buscar usuário por heartcode
  Future<Map<String, dynamic>?> getUsuarioPorHeartCode(String heartcode) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'heartcode = ?',
      whereArgs: [heartcode],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Atualizar status de conexão do usuário
  Future<void> updateConectado(int idUsuario, bool conectado) async {
    final db = await database;
    await db.update(
      'usuarios',
      {'conectado': conectado ? 1 : 0},
      where: 'id = ?',
      whereArgs: [idUsuario],
    );
  }

  // Inserir casal
  Future<void> insertCasal({
    required int idUsuario1,
    required int idUsuario2,
    required String codigoConexao,
  }) async {
    final db = await database;
    await db.insert('casais', {
      'idUsuario1': idUsuario1,
      'idUsuario2': idUsuario2,
      'codigoConexao': codigoConexao,
    });
  }

  Future<Map<String, dynamic>?> getCasalPorCodigo(String codigo) async {
    final db = await database;
    final result = await db.query(
      'casais',
      where: 'codigoConexao = ?',
      whereArgs: [codigo],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Inserir momento
  Future<void> insertMomento({
    required int idCasal,
    required String titulo,
    String? descricao,
    required String dataMomento,
    int foiRealizado = 0,
  }) async {
    final db = await database;
    await db.insert('momentos', {
      'idCasal': idCasal,
      'tituloMomento': titulo,
      'descricao': descricao ?? '',
      'dataMomento': dataMomento,
      'foiRealizado': foiRealizado,
    });
  }

  Future<List<Map<String, dynamic>>> getMomentosPorCasal(int idCasal) async {
    final db = await database;
    return await db.query(
      'momentos',
      where: 'idCasal = ?',
      whereArgs: [idCasal],
    );
  }

  // Inserir uso de celular
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

  // Obter uso de celular por usuário
  Future<List<Map<String, dynamic>>> getUsoCelularPorUsuario(int idUsuario) async {
    final db = await database;
    return await db.query(
      'uso_celular',
      where: 'idUsuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'dataUso DESC',
    );
  }

  // Obter dados de uso dos últimos 7 dias
  Future<List<Map<String, dynamic>>> getUsoCelularUltimaSemana(int idUsuario) async {
    final db = await database;
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    return await db.query(
      'uso_celular',
      where: 'idUsuario = ? AND dataUso >= ?',
      whereArgs: [idUsuario, lastWeek.toIso8601String().split('T')[0]],
      orderBy: 'dataUso ASC',
    );
  }

  // Calcular média semanal
  Future<double> getMediaSemanal(int idUsuario) async {
    final usageData = await getUsoCelularUltimaSemana(idUsuario);
    if (usageData.isEmpty) return 0.0;
    final totalMinutos = usageData.fold<int>(
      0,
          (sum, item) => sum + (item['tempoUsadoEmMinutos'] as int),
    );
    return totalMinutos / usageData.length;
  }

  // Obter tempo restante do dia atual
  Future<Map<String, dynamic>> getTempoRestante(int idUsuario, String dataUso) async {
    final db = await database;
    final result = await db.query(
      'uso_celular',
      where: 'idUsuario = ? AND dataUso = ?',
      whereArgs: [idUsuario, dataUso],
      limit: 1,
    );
    if (result.isEmpty) {
      return {'tempoRestante': 0, 'metaUso': 0, 'tempoUsado': 0};
    }
    final metaUso = result.first['metaUso'] as int;
    final tempoUsado = result.first['tempoUsadoEmMinutos'] as int;
    final tempoRestante = metaUso - tempoUsado;
    return {
      'tempoRestante': tempoRestante > 0 ? tempoRestante : 0,
      'metaUso': metaUso,
      'tempoUsado': tempoUsado,
    };
  }
}