import 'package:get_it/get_it.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import '../data/datasources/heart_code_remote_data_source.dart';
import 'package:heartsync/domain/repositories/heart_code_repository_impl.dart';
import '../domain/repositories/heart_code_repository.dart';
import '../domain/usecases/generate_heart_code_use_case.dart';
import '../presentation/viewmodels/heart_code_qr_viewmodel.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Database
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

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

  // ViewModels
  sl.registerFactory(() => HeartCodeQRViewModel(sl()));
}