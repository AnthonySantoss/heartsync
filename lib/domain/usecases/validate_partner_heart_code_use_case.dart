// lib/domain/usecases/validate_partner_heart_code_use_case.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import 'package:heartsync/core/errors/usecase.dart';
import '../entities/partner_heart_code.dart';
import '../repositories/heart_code_repository.dart';

class ValidatePartnerHeartCodeUseCase implements UseCase<PartnerHeartCode, ValidatePartnerHeartCodeParams> {
  final HeartCodeRepository repository;

  ValidatePartnerHeartCodeUseCase(this.repository);

  @override
  Future<Either<Failure, PartnerHeartCode>> call(ValidatePartnerHeartCodeParams params) async {
    return await repository.validatePartnerHeartCode(
      partnerHeartCode: params.partnerHeartCode,
      userHeartCode: params.userHeartCode,
    );
  }
}

class ValidatePartnerHeartCodeParams {
  final String partnerHeartCode;
  final String userHeartCode;

  ValidatePartnerHeartCodeParams({
    required this.partnerHeartCode,
    required this.userHeartCode,
  });
}