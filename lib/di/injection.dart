import 'package:get_it/get_it.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/servico/device_usage.dart'; // Assume que DeviceUsageService e AppUsageInfo estão aqui
import 'package:heartsync/data/repositories/usage_repository_impl.dart';
import 'package:heartsync/domain/usecases/register_user_use_case.dart';
import 'package:heartsync/servico/StatisticService.dart'; // Seu serviço de estatísticas agregado
import 'package:heartsync/domain/repositories/usage_repository.dart';
import 'package:heartsync/presentation/viewmodels/statistic_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  try {
    // Database
    // Removida a inicialização explícita e atribuição a 'databaseHelper' aqui,
    // pois DatabaseHelper.instance.init() ou DatabaseHelper.instance.database
    // já são chamados no main.dart para garantir a inicialização.
    // GetIt registrará a instância única.
    sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

    // Data Sources (nenhum explicitamente diferente do DeviceUsageService por enquanto)
    // Se DeviceUsageService fosse um "DataSource" formal, seria registrado aqui.

    // Services / Platform Channels Wrapper
    // DeviceUsageService é usado pelo UsageRepositoryImpl para buscar dados locais.
    sl.registerLazySingleton(() => DeviceUsageService());

    // Repositories
    sl.registerLazySingleton<UsageRepository>(
      // UsageRepositoryImpl agora depende de DeviceUsageService para dados locais.
          () => UsageRepositoryImpl(deviceUsageService: sl<DeviceUsageService>()),
    );

    // Use cases
    // Mantido o seu RegisterUserUseCase
    sl.registerLazySingleton(() => RegisterUserUseCase());
    // ou se não tiver dependência, apenas sl.registerLazySingleton(() => RegisterUserUseCase());

    // Outros Services (camada de serviço da sua aplicação)
    // StatisticService (o seu original) depende de DatabaseHelper e UsageRepository.
    // O UsageRepository injetado aqui fornecerá getTodayUsage e getUsageLimit.
    sl.registerLazySingleton<StatisticService>(
            () => StatisticService(sl<DatabaseHelper>()));


    // ViewModels
    // StatisticViewModel agora depende de UsageRepository.
    sl.registerFactory<StatisticViewModel>(
          () => StatisticViewModel(usageRepository: sl<UsageRepository>()),
    );

  } catch (e) {
    print('Erro ao inicializar dependências: $e');
    rethrow; // Propaga o erro para que possa ser tratado ou para falhar a inicialização.
  }
}