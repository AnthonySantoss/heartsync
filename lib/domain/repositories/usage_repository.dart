// lib/domain/repositories/usage_repository.dart
import 'package:heartsync/servico/device_usage.dart'; // Certifique-se que AppUsageInfo está aqui ou ajuste o import

abstract class UsageRepository {
  // Métodos para estatísticas de uso de apps locais (usados pelo StatisticViewModel)
  Future<bool> checkUsageStatsPermission();
  Future<bool> requestUsageStatsPermission();
  Future<List<AppUsageInfo>> getAppUsageStats();

  // Métodos para o StatisticService.dart (precisam de implementação real)
  /// Retorna o tempo de uso de hoje em HORAS para um usuário específico.
  /// A implementação real pode vir de um backend ou de agregação local.
  Future<double> getTodayUsage(int userId);

  /// Retorna o limite de tempo de uso em HORAS para um usuário específico.
  /// A implementação real pode vir de um backend.
  Future<double> getUsageLimit(int userId);
}