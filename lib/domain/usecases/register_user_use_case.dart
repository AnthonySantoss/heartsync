import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:get_it/get_it.dart';

class RegisterUserUseCase {
  final DatabaseHelper _databaseHelper = GetIt.instance<DatabaseHelper>();

  Future<int> execute({
    required String nome,
    required String email,
    required String dataNascimento,
    required String senha,
    required bool temFoto,
    String? profileImagePath, // Adicionado para suportar a foto de perfil
  }) async {
    // Verificar se o email já existe
    if (await _databaseHelper.emailExists(email)) {
      throw Exception('Email já registrado');
    }

    // Inserir usuário
    return await _databaseHelper.insertUsuario(
      nome: nome,
      email: email,
      dataNascimento: dataNascimento,
      senha: senha,
      temFoto: temFoto,
      profileImagePath: profileImagePath, // Passando o profileImagePath
    );
  }
}