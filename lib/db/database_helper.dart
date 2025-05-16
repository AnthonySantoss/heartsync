import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        dataNascimento TEXT,
        senha TEXT NOT NULL,
        temFoto INTEGER NOT NULL CHECK (temFoto IN (0,1)),
        heartcode TEXT NOT NULL CHECK (length(heartcode) >= 7 AND length(heartcode) <= 11),
        conectado INTEGER NOT NULL CHECK (conectado IN (0,1))
      )
    ''');

    // Tabela de casais
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

    // Tabela de momentos
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

    // Tabela de uso de celular
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

  // ======= MÉTODOS DE INSERÇÃO E CONSULTA =======

  // USUÁRIO
  Future<void> insertUsuario({
    required String nome,
    required String email,
    required String dataNascimento,
    required String senha,
    required bool temFoto,
    required String heartcode,
    required bool conectado,
  }) async {
    final db = await instance.database;
    await db.insert('usuarios', {
      'nome': nome,
      'email': email,
      'dataNascimento': dataNascimento,
      'senha': senha,
      'temFoto': temFoto ? 1 : 0,
      'heartcode': heartcode,
      'conectado': conectado ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final db = await instance.database;
    return await db.query('usuarios', orderBy: 'id DESC');
  }

  // CASAL
  Future<void> insertCasal({
    required int idUsuario1,
    required int idUsuario2,
    required String codigoConexao,
  }) async {
    final db = await instance.database;
    await db.insert('casais', {
      'idUsuario1': idUsuario1,
      'idUsuario2': idUsuario2,
      'codigoConexao': codigoConexao,
    });
  }

  Future<Map<String, dynamic>?> getCasalPorCodigo(String codigo) async {
    final db = await instance.database;
    final result = await db.query(
      'casais',
      where: 'codigoConexao = ?',
      whereArgs: [codigo],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // MOMENTO
  Future<void> insertMomento({
    required int idCasal,
    required String titulo,
    String? descricao,
    required String dataMomento,
    int foiRealizado = 0,
  }) async {
    final db = await instance.database;
    await db.insert('momentos', {
      'idCasal': idCasal,
      'tituloMomento': titulo,
      'descricao': descricao ?? '',
      'dataMomento': dataMomento,
      'foiRealizado': foiRealizado,
    });
  }

  Future<List<Map<String, dynamic>>> getMomentosPorCasal(int idCasal) async {
    final db = await instance.database;
    return await db.query(
      'momentos',
      where: 'idCasal = ?',
      whereArgs: [idCasal],
    );
  }

  // USO CELULAR
  Future<void> insertUsoCelular({
    required int idUsuario,
    required String dataUso,
    required int tempoUsadoEmMinutos,
    required int metaUso,
  }) async {
    final db = await instance.database;
    await db.insert('uso_celular', {
      'idUsuario': idUsuario,
      'dataUso': dataUso,
      'tempoUsadoEmMinutos': tempoUsadoEmMinutos,
      'metaUso': metaUso,
    });
  }

  Future<List<Map<String, dynamic>>> getUsoCelularPorUsuario(int idUsuario) async {
    final db = await instance.database;
    return await db.query(
      'uso_celular',
      where: 'idUsuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'dataUso DESC',
    );
  }
}
