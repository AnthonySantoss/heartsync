import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/user.dart';
import '../entities/partner_heart_code.dart';

abstract class HeartCodeRepository {
  Future<Either<Failure, User>> generateHeartCode({
    required String name,
    required String birth,
    required String email,
    required String password,
    String? profileImagePath,
  });

  Future<Either<Failure, PartnerHeartCode>> validatePartnerHeartCode({
    required String partnerHeartCode,
    required String userHeartCode,
  });
}

