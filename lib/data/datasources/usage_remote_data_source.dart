import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/servico/device_usage.dart';

abstract class UsageRemoteDataSource {
  Future<double> getDeviceUsageToday(int userId);
  Future<List<double>> getWeeklyUsage(int userId);
  Future<double?> getUsageLimit(int userId); // Adicionado para corresponder ao UsageRepository
}

class UsageRemoteDataSourceImpl implements UsageRemoteDataSource {
  final DatabaseHelper databaseHelper;

  UsageRemoteDataSourceImpl(this.databaseHelper);

  @override
  Future<double> getDeviceUsageToday(int userId) async {
    try {
      final hasPermission = await DeviceUsage.checkUsagePermission();
      if (hasPermission) {
        final minutes = await DeviceUsage.getDeviceUsageTimeWithPermission();
        return minutes / 60.0; // Converter minutos para horas
      }
      print('Permissão negada ou erro ao obter uso do dispositivo. Usando valor mock.');
      return 2.5; // 2.5 horas como valor mock
    } catch (e) {
      print('Erro ao obter uso do dispositivo: $e. Usando valor mock.');
      return 2.5;
    }
  }

  @override
  Future<List<double>> getWeeklyUsage(int userId) async {
    try {
      final db = await databaseHelper.database;
      final startDate = DateTime.now().subtract(const Duration(days: 6)).toIso8601String().split('T')[0];
      final result = await db.query(
        'uso_celular',
        where: 'idUsuario = ? AND dataUso >= ?',
        whereArgs: [userId, startDate],
        orderBy: 'dataUso ASC',
      );

      final usageData = <double>[];
      final currentDate = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = currentDate.subtract(Duration(days: i)).toIso8601String().split('T')[0];
        final entry = result.firstWhere(
              (e) => e['dataUso'] == date,
          orElse: () => {'tempoUsadoEmMinutos': 0},
        );
        usageData.add((entry['tempoUsadoEmMinutos'] as int) / 60.0);
      }

      return usageData;
    } catch (e) {
      print('Erro ao obter uso semanal: $e. Retornando lista vazia.');
      return List<double>.filled(7, 0.0);
    }
  }

  @override
  Future<double?> getUsageLimit(int userId) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.query(
        'uso_celular',
        where: 'idUsuario = ?',
        whereArgs: [userId],
        orderBy: 'dataUso DESC',
        limit: 1,
      );

      if (result.isNotEmpty) {
        final metaUso = result.first['metaUso'] as int? ?? 240; // 4 horas em minutos
        return metaUso / 60.0; // Converter minutos para horas
      }
      return 4.0; // Valor padrão: 4 horas
    } catch (e) {
      print('Erro ao obter limite de uso: $e. Usando valor padrão.');
      return 4.0; // Valor padrão em caso de erro
    }
  }
}