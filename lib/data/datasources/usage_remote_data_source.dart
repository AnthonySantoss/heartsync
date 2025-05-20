
import 'package:heartsync/data/datasources/database_helper.dart';

abstract class UsageRemoteDataSource {
  Future<double> getDeviceUsageToday();
  Future<List<double>> getWeeklyUsage(int userId);
}

class UsageRemoteDataSourceImpl implements UsageRemoteDataSource {
  final DatabaseHelper databaseHelper;

  UsageRemoteDataSourceImpl(this.databaseHelper);

  @override
  Future<double> getDeviceUsageToday() async {
    // Implementação real usaria Device Usage API
    // Esta é uma implementação mock para exemplo
    return 2.5; // Retorna 2.5 horas de uso hoje
  }

  @override
  Future<List<double>> getWeeklyUsage(int userId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'uso_celular',
      where: 'idUsuario = ?',
      whereArgs: [userId],
      orderBy: 'dataUso DESC',
      limit: 7,
    );

    return result.map((e) => (e['tempoUsadoEmMinutos'] as int) / 60.0).toList();
  }
}