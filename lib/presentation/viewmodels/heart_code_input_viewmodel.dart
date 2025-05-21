import 'package:flutter/foundation.dart';
import 'package:heartsync/domain/usecases/register_user_use_case.dart';
import 'package:uuid/uuid.dart';

class HeartCodeInputViewModel extends ChangeNotifier {
  final RegisterUserUseCase _registerUserUseCase;
  bool _isLoading = false;
  String? _error;

  HeartCodeInputViewModel(this._registerUserUseCase);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> validateHeartCode({
    required String userHeartCode,
    required String partnerHeartCode,
    required VoidCallback onSuccess,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gerar um código de conexão único
      final codigoConexao = 'CONN${const Uuid().v4().substring(0, 8).toUpperCase()}';

      // Conectar os usuários usando o RegisterUserUseCase
      await _registerUserUseCase.connectUsers(
        userHeartCode: userHeartCode,
        partnerHeartCode: partnerHeartCode,
        codigoConexao: codigoConexao,
      );

      // Se não houver exceção, a conexão foi bem-sucedida
      onSuccess();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      print('Erro ao validar HeartCode: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}