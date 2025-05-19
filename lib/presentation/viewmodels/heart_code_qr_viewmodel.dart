import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/generate_heart_code_use_case.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';

class HeartCodeQRViewModel extends ChangeNotifier {
  final GenerateHeartCodeUseCase _generateHeartCodeUseCase;

  HeartCodeQRViewModel(this._generateHeartCodeUseCase);

  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> generateHeartCode({
    required String name,
    required String birth,
    required String email,
    required String password,
    String? profileImagePath,
  }) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _generateHeartCodeUseCase(
        GenerateHeartCodeParams(
          name: name,
          birth: birth,
          email: email,
          password: password,
          profileImagePath: profileImagePath,
        ),
      );

      result.fold(
            (failure) {
          _error = _mapFailureToMessage(failure);
          _isLoading = false;
          notifyListeners();
          print('Erro ao gerar Heart Code: $_error');
        },
            (generatedUser) {
          _user = generatedUser;
          _successMessage = 'Heart Code gerado com sucesso!';
          _isLoading = false;
          notifyListeners();
          print('Heart Code gerado: ${generatedUser.heartCode}, QR Code: ${generatedUser.qrCodeUrl}');
        },
      );
    } catch (e) {
      _error = 'Erro inesperado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print('Erro inesperado no ViewModel: $_error');
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Falha no servidor. Tente novamente mais tarde.';
      case NetworkFailure:
        return 'Sem conexão com a internet. Verifique sua rede.';
      case CacheFailure:
        return 'Falha ao acessar dados locais.';
      default:
        return 'Erro ao gerar o Heart Code';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }
}