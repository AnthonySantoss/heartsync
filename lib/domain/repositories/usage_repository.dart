import 'package:heartsync/data/datasources/usage_remote_data_source.dart';

abstract class UsageRepository {
  Future<double> getTodayUsage(int userId);
  Future<List<double>> getWeeklyUsage(int userId);
  Future<double> getUsageLimit(int userId);
}

class UsageRepositoryImpl implements UsageRepository {
  final UsageRemoteDataSource remoteDataSource;

  UsageRepositoryImpl(this.remoteDataSource);

  @override
  Future<double> getTodayUsage(int userId) => remoteDataSource.getDeviceUsageToday(userId);

  @override
  Future<List<double>> getWeeklyUsage(int userId) => remoteDataSource.getWeeklyUsage(userId);

  @override
  Future<double> getUsageLimit(int userId) async {
    return await remoteDataSource.getUsageLimit(userId) ?? 4.0; // 4 horas por padrão
  }
}