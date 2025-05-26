import 'package:heartsync/domain/repositories/usage_repository.dart';
import 'package:heartsync/servico/device_usage.dart'; // Contém DeviceUsageService e AppUsageInfo
// Importe o device_apps para uma verificação de fallback ou mais detalhada se necessário no futuro
// import 'package:device_apps/device_apps.dart';


class UsageRepositoryImpl implements UsageRepository {
  final DeviceUsageService deviceUsageService;

  UsageRepositoryImpl({required this.deviceUsageService});

  @override
  Future<bool> checkUsageStatsPermission() {
    return deviceUsageService.checkUsageStatsPermission();
  }

  /// Retorna a lista de AppUsageInfo, já contendo a flag isSystemApp do nativo.
  @override
  Future<List<AppUsageInfo>> getAppUsageStats({bool includeSystemApps = false}) async {
    final List<Map<dynamic, dynamic>> statsMaps =
    await deviceUsageService.getAppUsageStats(); // Esta chamada já retorna dados do dia atual

    var infos = statsMaps.map((map) => AppUsageInfo.fromMap(map)).toList();

    if (!includeSystemApps) {
      infos.removeWhere((info) => info.isSystemApp);
    }
    // Log para verificar os apps filtrados
    // print("UsageRepositoryImpl: getAppUsageStats (includeSystemApps: $includeSystemApps) - ${infos.length} apps após filtro:");
    // infos.forEach((info) => print(info));
    return infos;
  }


  @override
  Future<bool> requestUsageStatsPermission() {
    return deviceUsageService.requestUsageStatsPermission();
  }

  // --- Métodos para StatisticService.dart ---

  /// Calcula o uso total de apps NÃO-SISTEMA para o dia atual em HORAS.
  @override
  Future<double> getTodayUsage(int userId) async {
    print(
        'UsageRepositoryImpl: getTodayUsage para userId $userId chamado. Buscando uso de apps não-sistema.');

    try {
      // Pega apenas apps não-sistema
      final List<AppUsageInfo> stats = await getAppUsageStats(includeSystemApps: false);
      if (stats.isEmpty) return 0.0;

      // Soma o tempo de uso dos apps não-sistema
      int totalUsageMs = stats.fold(
          0, (sum, item) => sum + item.totalTimeInForegroundMs);

      double hours = totalUsageMs / (1000 * 60 * 60);
      print('UsageRepositoryImpl: Total de uso hoje (não-sistema): $hours horas ($totalUsageMs ms) de ${stats.length} apps.');
      return hours;
    } catch (e) {
      print("Erro ao calcular getTodayUsage no Impl: $e");
      return 0.0;
    }
  }

  /// Busca o uso de apps NÃO-SISTEMA para os últimos `daysCount` dias.
  /// Retorna um Map onde a chave é a data (no início do dia) e o valor é a Duração do uso.
  /// NOTA: O `DeviceUsageService` e o código nativo atual buscam apenas "hoje".
  /// Para buscar por vários dias, o código nativo `getAppUsageStatsToday` precisaria ser
  /// generalizado para aceitar `startTime` e `endTime` e ser chamado repetidamente.
  /// Ou, você pode usar um plugin como `app_usage` que já oferece essa funcionalidade.
  /// Por simplicidade e com base no código existente, esta função no repositório
  /// ainda só consegue retornar dados de "hoje".
  /// Para dados semanais, precisaremos adaptar o `StatisticService` ou o `ViewModel`
  /// para chamar isso diariamente e armazenar, ou modificar o nativo.
  ///
  /// **SOLUÇÃO INTERMEDIÁRIA**: Vamos modificar o `StatisticService` para simular
  /// a busca diária, mas idealmente isso seria feito no nativo ou com um plugin mais robusto
  /// para performance e precisão.
  ///
  /// **ATUALIZAÇÃO**: O `DeviceUsageService.getAppUsageStats()` já busca dados do dia atual.
  /// Para dados semanais, o `StatisticService` ou `StatisticViewModel` precisará de uma nova lógica
  /// para chamar o método nativo para cada dia da semana.
  /// **Vamos assumir que `getAppUsageStats` (via `DeviceUsageService`) retorna dados para o dia atual
  /// e o `StatisticService` ou `ViewModel` irá orquestrar chamadas diárias se necessário
  /// ou usaremos uma nova abordagem no `StatisticService` para buscar dados dos últimos 7 dias.
  Future<Map<DateTime, Duration>> getDailyUsageNonSystem(int daysToFetch) async {
    Map<DateTime, Duration> dailyUsage = {};
    // O código nativo atual SÓ retorna dados de HOJE.
    // Para obter dados de dias anteriores, o MainActivity.kt precisaria ser modificado
    // para aceitar startDate e endDate no método getAppUsageStats.
    // Por ora, vamos retornar o uso de hoje mapeado para hoje.
    // A lógica de agregação semanal terá que ser mais inteligente ou adaptada.

    if (daysToFetch <= 0) return dailyUsage;

    // Simulação: Se quisermos dados de "hoje", chamamos uma vez.
    // Para um gráfico semanal REAL, precisaríamos modificar o código nativo
    // ou usar um plugin que suporte busca por intervalo.
    // Para este exemplo, vou focar em obter o uso de "hoje" filtrado
    // e o StatisticService/ViewModel cuidará de como apresentar isso semanalmente.

    final List<AppUsageInfo> statsToday = await getAppUsageStats(includeSystemApps: false);
    int totalUsageMsToday = statsToday.fold(0, (sum, item) => sum + item.totalTimeInForegroundMs);
    DateTime today = DateTime.now();
    DateTime startOfToday = DateTime(today.year, today.month, today.day);
    dailyUsage[startOfToday] = Duration(milliseconds: totalUsageMsToday);

    // PARA DADOS SEMANAIS REAIS:
    // Você precisaria de um método em DeviceUsageService e MainActivity que aceite
    // um intervalo de datas. Ex: getAppUsageStatsForInterval(startTime, endTime)
    // E então iterar aqui:
    // for (int i = 0; i < daysToFetch; i++) {
    //   DateTime targetDay = DateTime.now().subtract(Duration(days: i));
    //   DateTime startTime = DateTime(targetDay.year, targetDay.month, targetDay.day);
    //   DateTime endTime = DateTime(targetDay.year, targetDay.month, targetDay.day, 23, 59, 59);
    //   final List<AppUsageInfo> statsForDay = await deviceUsageService.getAppUsageStatsForInterval(startTime.millisecondsSinceEpoch, endTime.millisecondsSinceEpoch, includeSystemApps: false);
    //   int totalUsageMs = statsForDay.fold(0, (sum, item) => sum + item.totalTimeInForegroundMs);
    //   dailyUsage[startTime] = Duration(milliseconds: totalUsageMs);
    // }
    return dailyUsage;
  }


  @override
  Future<double> getUsageLimit(int userId) async {
    // Mantém sua lógica existente ou busca de um backend/local storage.
    print(
        'UsageRepositoryImpl: getUsageLimit para userId $userId chamado - PRECISA DE IMPLEMENTAÇÃO SE FOR DINÂMICO');
    return 2.0; // Exemplo: 2 horas
  }
}