import 'package:heartsync/domain/repositories/usage_repository.dart';
import 'package:heartsync/servico/device_usage.dart'; // Contém DeviceUsageService e AppUsageInfo

class UsageRepositoryImpl implements UsageRepository {
  final DeviceUsageService deviceUsageService;

  UsageRepositoryImpl({required this.deviceUsageService});

  // Métodos implementados para estatísticas locais de uso de apps
  @override
  Future<bool> checkUsageStatsPermission() {
    return deviceUsageService.checkUsageStatsPermission();
  }

  @override
  Future<List<AppUsageInfo>> getAppUsageStats() async {
    // O DeviceUsageService.getAppUsageStats() retorna Future<List<Map<dynamic, dynamic>>>
    // Precisamos mapear para Future<List<AppUsageInfo>>
    final List<Map<dynamic, dynamic>> statsMaps =
    await deviceUsageService.getAppUsageStats();
    return statsMaps.map((map) => AppUsageInfo.fromMap(map)).toList();
  }

  @override
  Future<bool> requestUsageStatsPermission() {
    return deviceUsageService.requestUsageStatsPermission();
  }

  // --- Métodos para StatisticService.dart ---

  @override
  Future<double> getTodayUsage(int userId) async {
    // TODO: Implementar a lógica real para buscar o uso diário em HORAS
    //       específico para o userId, se necessário.
    //       A implementação atual soma o tempo de todos os apps retornados
    //       pelo deviceUsageService para o dia (INTERVAL_DAILY).
    //       Se você precisar filtrar por `userId` aqui, a lógica precisaria
    //       de acesso a dados do usuário ou o `DeviceUsageService` precisaria
    //       de alguma forma de filtrar isso (o que não é comum para APIs de uso de sistema).
    //       Esta função atualmente retorna o uso total do dispositivo para o dia.
    print(
        'UsageRepositoryImpl: getTodayUsage para userId $userId chamado. ATENÇÃO: Retornando uso total do dispositivo, não filtrado por usuário.');

    try {
      // getAppUsageStats agora retorna List<AppUsageInfo> diretamente
      final List<AppUsageInfo> stats = await getAppUsageStats();
      if (stats.isEmpty) return 0.0;

      // O DeviceUsageService (e o código nativo) já deve retornar os dados
      // agregados para o intervalo diário (INTERVAL_DAILY).
      // Portanto, somamos o totalTimeInForegroundMs de todas as entradas.
      int totalUsageMs = stats.fold(
          0, (sum, item) => sum + item.totalTimeInForegroundMs);

      return totalUsageMs / (1000 * 60 * 60); // Convertendo milissegundos para horas
    } catch (e) {
      print("Erro ao calcular getTodayUsage no Impl: $e");
      return 0.0; // Retorna 0.0 em caso de erro
    }
  }

  @override
  Future<double> getUsageLimit(int userId) async {
    // TODO: Implementar a lógica real para buscar o limite de uso em HORAS para o userId.
    // Exemplo:
    // 1. Poderia buscar de um backend.
    // 2. Poderia buscar de SharedPreferences ou DatabaseHelper se configurado localmente para este userId.
    print(
        'UsageRepositoryImpl: getUsageLimit para userId $userId chamado - PRECISA DE IMPLEMENTAÇÃO');
    // Retornando um valor mockado por enquanto.
    return 2.0; // Exemplo: 2 horas
  }
}