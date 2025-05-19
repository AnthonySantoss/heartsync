import 'package:get_it/get_it.dart';
import 'package:heartsync/domain/usecases/validate_partner_heart_code_use_case.dart';
import 'package:heartsync/presentation/viewmodels/heart_code_input_viewmodel.dart';
import '../data/datasources/heart_code_remote_data_source.dart';
import 'package:heartsync/domain/repositories/heart_code_repository_impl.dart';
import '../domain/repositories/heart_code_repository.dart';
import '../domain/usecases/generate_heart_code_use_case.dart';
import '../presentation/viewmodels/heart_code_qr_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Data sources
  sl.registerLazySingleton<HeartCodeRemoteDataSource>(
        () => HeartCodeRemoteDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<HeartCodeRepository>(
        () => HeartCodeRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GenerateHeartCodeUseCase(sl()));
  sl.registerLazySingleton(() => ValidatePartnerHeartCodeUseCase(sl()));
  // ViewModels
  sl.registerFactory(() => HeartCodeQRViewModel(sl()));
  sl.registerFactory(() => HeartCodeInputViewModel(sl()));
}