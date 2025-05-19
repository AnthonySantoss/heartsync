import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/usecase.dart';
import '../entities/user.dart';
import '../repositories/heart_code_repository.dart';

class GenerateHeartCodeUseCase implements UseCase<User, GenerateHeartCodeParams> {
  final HeartCodeRepository repository;

  GenerateHeartCodeUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(GenerateHeartCodeParams params) async {
    return await repository.generateHeartCode(
      name: params.name,
      birth: params.birth,
      email: params.email,
      password: params.password,
      profileImagePath: params.profileImagePath,
    );
  }
}

class GenerateHeartCodeParams {
  final String name;
  final String birth;
  final String email;
  final String password;
  final String? profileImagePath;

  GenerateHeartCodeParams({
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
    this.profileImagePath,
  });
}