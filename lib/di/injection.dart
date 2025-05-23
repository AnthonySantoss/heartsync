import 'package:get_it/get_it.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/data/datasources/usage_remote_data_source.dart';
import 'package:heartsync/domain/usecases/register_user_use_case.dart';
import 'package:heartsync/servico/StatisticService.dart';
import 'package:heartsync/domain/repositories/usage_repository.dart';
import 'package:heartsync/presentation/viewmodels/statistic_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  try {
    // Database
    // Garantir que o DatabaseHelper seja inicializado corretamente
    final databaseHelper = await DatabaseHelper.instance.init();
    sl.registerLazySingleton<DatabaseHelper>(() => databaseHelper);

    // Data Sources
    sl.registerLazySingleton<UsageRemoteDataSource>(() => UsageRemoteDataSourceImpl(sl<DatabaseHelper>()));

    // Repositories
    sl.registerLazySingleton<UsageRepository>(() => UsageRepositoryImpl(sl<UsageRemoteDataSource>()));

    // Use cases
    sl.registerLazySingleton(() => RegisterUserUseCase());

    // Services
    sl.registerLazySingleton<StatisticService>(() => StatisticService(sl<DatabaseHelper>()));

    // ViewModels
    sl.registerFactory(() => StatisticViewModel(sl<StatisticService>()));
  } catch (e) {
    print('Erro ao inicializar dependências: $e');
    rethrow;
  }
}