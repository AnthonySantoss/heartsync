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
      return List<Map<dynamic, dynamic>>.from(stats.map((item) => item as Map<dynamic, dynamic>));
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        print("Permissão de acesso ao uso não concedida. Solicite ao usuário.");
        throw Exception("Permissão de acesso ao uso negada.");
      } else {
        print("Erro ao buscar estatísticas de uso: ${e.message}");
      }
      return [];
    }
  }
}

// Modelo para os dados de uso
class AppUsageInfo {
  final String packageName;
  final String appName;
  final int totalTimeInForegroundMs; // Milissegundos
  final int lastTimeUsedMs; // Milissegundos desde a época
  final bool isSystemApp; // ADICIONADO

  AppUsageInfo({
    required this.packageName,
    required this.appName,
    required this.totalTimeInForegroundMs,
    required this.lastTimeUsedMs,
    required this.isSystemApp, // ADICIONADO
  });

  factory AppUsageInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppUsageInfo(
      packageName: map['packageName'] ?? 'N/A',
      appName: map['appName'] ?? 'N/A',
      totalTimeInForegroundMs: map['totalTimeInForeground'] ?? 0,
      lastTimeUsedMs: map['lastTimeUsed'] ?? 0,
      isSystemApp: map['isSystemApp'] ?? true, // ADICIONADO - Assume true se não vier para filtrar por segurança
    );
  }

  Duration get usageDuration => Duration(milliseconds: totalTimeInForegroundMs);
  DateTime get lastUsedDateTime => DateTime.fromMillisecondsSinceEpoch(lastTimeUsedMs);

  @override
  String toString() {
    return 'App: $appName, Pkg: $packageName, Usage: ${usageDuration.inMinutes} min, System: $isSystemApp, Last Used: $lastUsedDateTime';
  }
}