// lib/presentation/viewmodels/heart_code_input_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:heartsync/domain/repositories/heart_code_repository_impl.dart';
import '../../../domain/entities/partner_heart_code.dart';
import '../../../domain/usecases/validate_partner_heart_code_use_case.dart';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';

class HeartCodeInputViewModel extends ChangeNotifier {
  final ValidatePartnerHeartCodeUseCase _validatePartnerHeartCodeUseCase;
  bool _isLoading = false;
  String? _error;

  HeartCodeInputViewModel(this._validatePartnerHeartCodeUseCase);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> validateHeartCode({
    required String partnerHeartCode,
    required String userHeartCode,
    required VoidCallback onSuccess,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Comentário: Valida o Heart Code do parceiro
      final result = await _validatePartnerHeartCodeUseCase(
        ValidatePartnerHeartCodeParams(
          partnerHeartCode: partnerHeartCode,
          userHeartCode: userHeartCode,
        ),
      );

      result.fold(
            (failure) {
          _error = _mapFailureToMessage(failure);
          _isLoading = false;
          notifyListeners();
          print('Erro ao validar Heart Code: $_error'); // Debug
        },
            (partner) {
          _isLoading = false;
          notifyListeners();
          onSuccess(); // Comentário: Chama a callback de sucesso
          print('Heart Code validado com sucesso: ${partner.code}');
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
      case InvalidHeartCodeFailure:
        return 'Heart Code inválido ou igual ao seu!';
      case NetworkFailure:
        return 'Sem conexão com a internet. Verifique sua rede.';
      default:
        return 'Erro ao validar o Heart Code';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}