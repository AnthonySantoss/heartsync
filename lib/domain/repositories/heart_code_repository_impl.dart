import 'package:dartz/dartz.dart';
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
}