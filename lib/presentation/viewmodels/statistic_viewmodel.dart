import 'package:flutter/material.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/domain/repositories/usage_repository.dart';

class StatisticViewModel extends ChangeNotifier {
  final UsageRepository usageRepository;
  final DatabaseHelper databaseHelper;

  StatisticViewModel(this.usageRepository, this.databaseHelper);

  double _todayUsage = 0;
  double _usageLimit = 4.0;
  List<double> _weeklyUsage = [];
  String _remainingTime = '0h0min';
  String _totalTimeUsed = '0h0min';

  double get todayUsage => _todayUsage;
  double get usageLimit => _usageLimit;
  List<double> get weeklyUsage => _weeklyUsage;
  String get remainingTime => _remainingTime;
  String get totalTimeUsed => _totalTimeUsed;

  Future<void> loadUsageData(int userId) async {
    _todayUsage = await usageRepository.getTodayUsage();
    _usageLimit = await usageRepository.getUsageLimit();
    _weeklyUsage = await usageRepository.getWeeklyUsage(userId);

    // Calcular tempo restante
    final remaining = _usageLimit - _todayUsage;
    final hours = remaining.floor();
    final minutes = ((remaining - hours) * 60).round();
    _remainingTime = '${hours}h${minutes}min';

    // Calcular tempo total usado
    final usedHours = _todayUsage.floor();
    final usedMinutes = ((_todayUsage - usedHours) * 60).round();
    _totalTimeUsed = '${usedHours}h${usedMinutes}min';

    notifyListeners();
  }

  String formatWeeklyAverage() {
    if (_weeklyUsage.isEmpty) return '0 min';

    final average = _weeklyUsage.reduce((a, b) => a + b) / _weeklyUsage.length;
    final minutes = (average * 60).round();
    return '$minutes min';
  }
}