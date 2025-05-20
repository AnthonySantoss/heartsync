
import 'package:heartsync/data/datasources/usage_remote_data_source.dart';

abstract class UsageRepository {
  Future<double> getTodayUsage();
  Future<List<double>> getWeeklyUsage(int userId);
  Future<double> getUsageLimit();
}

class UsageRepositoryImpl implements UsageRepository {
  final UsageRemoteDataSource remoteDataSource;

  UsageRepositoryImpl(this.remoteDataSource);

  @override
  Future<double> getTodayUsage() => remoteDataSource.getDeviceUsageToday();

  @override
  Future<List<double>> getWeeklyUsage(int userId) =>
      remoteDataSource.getWeeklyUsage(userId);

  @override
  Future<double> getUsageLimit() async {
    // Pode ser obtido do banco de dados ou de preferências
    return 4.0; // 4 horas por padrão
  }
}