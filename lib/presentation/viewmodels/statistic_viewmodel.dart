import 'package:flutter/material.dart';
import 'package:heartsync/servico/StatisticService.dart';

class StatisticViewModel extends ChangeNotifier {
  final StatisticService statisticService;

  StatisticViewModel(this.statisticService);

  Map<String, dynamic>? _statisticData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get statisticData => _statisticData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStatisticData(int userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await statisticService.getStatisticData(
        userId,
        DateTime.now().toIso8601String().split('T')[0],
      );

      _statisticData = data;
    } catch (e) {
      _error = 'Erro ao carregar dados: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatWeeklyAverage() {
    if (_statisticData == null || _statisticData!['weeklyAverage'] == null) {
      return '0 min';
    }
    return _statisticData!['weeklyAverage'];
  }
}