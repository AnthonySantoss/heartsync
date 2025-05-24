import 'package:flutter/services.dart';

class DeviceUsageService {
  static const MethodChannel _channel =
  MethodChannel('com.example.heartsync/usage_stats'); // Mesmo nome do canal definido no Kotlin

  Future<bool> checkUsageStatsPermission() async {
    try {
      final bool? granted = await _channel.invokeMethod('checkUsageStatsPermission');
      return granted ?? false;
    } on PlatformException catch (e) {
      print("Erro ao verificar permissão: ${e.message}");
      return false;
    }
  }

  Future<bool> requestUsageStatsPermission() async {
    try {
      // Este método nativo tentará abrir as configurações do sistema.
      // O resultado 'true' aqui significa que a tentativa foi feita.
      // A permissão real precisa ser verificada novamente depois que o usuário retornar ao app.
      final bool? success = await _channel.invokeMethod('requestUsageStatsPermission');
      return success ?? false;
    } on PlatformException catch (e) {
      print("Erro ao solicitar permissão: ${e.message}");
      return false;
    }
  }

  Future<List<Map<dynamic, dynamic>>> getAppUsageStats() async {
    try {
      final List<dynamic>? stats =
      await _channel.invokeMethod('getAppUsageStats');
      if (stats == null) {
        return [];
      }
      // O resultado já vem como List<Map<String, Any?>> do Kotlin,
      // o 'dynamic' aqui é para segurança de tipo no Dart.
      return List<Map<dynamic, dynamic>>.from(stats.map((item) => item as Map<dynamic, dynamic>));
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        print("Permissão de acesso ao uso não concedida. Solicite ao usuário.");
        // Você pode querer lançar um erro customizado aqui ou retornar um valor específico
        // para que a UI possa reagir e chamar requestUsageStatsPermission().
        throw Exception("Permissão de acesso ao uso negada.");
      } else {
        print("Erro ao buscar estatísticas de uso: ${e.message}");
      }
      return [];
    }
  }
}

// Modelo para os dados de uso (opcional, mas recomendado)
class AppUsageInfo {
  final String packageName;
  final String appName;
  final int totalTimeInForegroundMs; // Milissegundos
  final int lastTimeUsedMs; // Milissegundos desde a época

  AppUsageInfo({
    required this.packageName,
    required this.appName,
    required this.totalTimeInForegroundMs,
    required this.lastTimeUsedMs,
  });

  factory AppUsageInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppUsageInfo(
      packageName: map['packageName'] ?? 'N/A',
      appName: map['appName'] ?? 'N/A',
      totalTimeInForegroundMs: map['totalTimeInForeground'] ?? 0,
      lastTimeUsedMs: map['lastTimeUsed'] ?? 0,
    );
  }

  Duration get usageDuration => Duration(milliseconds: totalTimeInForegroundMs);
  DateTime get lastUsedDateTime => DateTime.fromMillisecondsSinceEpoch(lastTimeUsedMs);

  @override
  String toString() {
    return 'App: $appName, Usage: ${usageDuration.inMinutes} min, Last Used: $lastUsedDateTime';
  }
}