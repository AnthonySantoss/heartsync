import 'package:dartz/dartz.dart';
import 'package:heartsync/domain/entities/partner_heart_code.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/heart_code_repository.dart';
import '../../data/datasources/heart_code_remote_data_source.dart';

class HeartCodeRepositoryImpl implements HeartCodeRepository {
  final HeartCodeRemoteDataSource remoteDataSource;

  HeartCodeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> generateHeartCode({
    required String name,
    required String birth,
    required String email,
    required String password,
    String? profileImagePath,
  }) async {
    try {
      final userModel = await remoteDataSource.generateHeartCode(
        name: name,
        birth: birth,
        email: email,
        password: password,
        profileImagePath: profileImagePath,
      );
      return Right(userModel);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PartnerHeartCode>> validatePartnerHeartCode({
    required String partnerHeartCode,
    required String userHeartCode,
  }) async {
    try {
      // Comentário: Tenta validar o Heart Code do parceiro
      final partner = await remoteDataSource.validatePartnerHeartCode(
        partnerHeartCode: partnerHeartCode,
        userHeartCode: userHeartCode,
      );
      return Right(partner); // Comentário: Retorna sucesso se válido
    } on ServerException {
      return Left(ServerFailure()); // Comentário: Trata falhas do servidor
    } on InvalidHeartCodeException {
      return Left(InvalidHeartCodeFailure()); // Comentário: Trata Heart Code inválido
    } catch (e) {
      return Left(ServerFailure()); // Comentário: Trata erros genéricos
    }
  }
}

// Falha personalizada para Heart Code inválido
class InvalidHeartCodeFailure extends Failure {}