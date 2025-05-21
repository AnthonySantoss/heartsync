import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class RegisterUserUseCase {
  final DatabaseHelper _databaseHelper = GetIt.instance<DatabaseHelper>();

  Future<int> execute({
    required String nome,
    required String email,
    required String dataNascimento,
    required String senha,
    required bool temFoto,
    required String heartcode,
  }) async {
    // Verificar se o email já existe
    if (await _databaseHelper.emailExists(email)) {
      throw Exception('Email já registrado');
    }

    // Verificar se o heartcode já existe
    if (await _databaseHelper.heartCodeExists(heartcode)) {
      throw Exception('HeartCode já está em uso');
    }

    // Inserir usuário
    return await _databaseHelper.insertUsuario(
      nome: nome,
      email: email,
      dataNascimento: dataNascimento,
      senha: senha,
      temFoto: temFoto,
      heartcode: heartcode,
      conectado: false,
    );
  }

  Future<void> connectUsers({
    required String userHeartCode,
    required String partnerHeartCode,
    required String codigoConexao,
  }) async {
    // Buscar usuários
    final user = await _databaseHelper.getUsuarioPorHeartCode(userHeartCode);
    final partner = await _databaseHelper.getUsuarioPorHeartCode(partnerHeartCode);

    if (user == null || partner == null) {
      throw Exception('Usuário ou parceiro não encontrado');
    }

    if (user['conectado'] == 1 || partner['conectado'] == 1) {
      throw Exception('Um dos usuários já está conectado');
    }

    // Inserir casal
    await _databaseHelper.insertCasal(
      idUsuario1: user['id'],
      idUsuario2: partner['id'],
      codigoConexao: codigoConexao,
    );

    // Atualizar status de conexão
    await _databaseHelper.updateConectado(user['id'], true);
    await _databaseHelper.updateConectado(partner['id'], true);
  }
}