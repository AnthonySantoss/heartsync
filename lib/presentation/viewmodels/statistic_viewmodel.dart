// lib/presentation/viewmodels/statistic_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:heartsync/domain/repositories/usage_repository.dart';
import 'package:heartsync/servico/device_usage.dart'; // Para AppUsageInfo
import 'package:heartsync/servico/StatisticService.dart'; // Seu serviço existente
import 'package:get_it/get_it.dart'; // Para GetIt

class StatisticViewModel extends ChangeNotifier {
  final UsageRepository _usageRepository;
  final StatisticService _statisticService = GetIt.instance<StatisticService>(); // Pegando do GetIt

  // Para a lista de apps (se você quiser mostrar em algum lugar, talvez em outra aba/seção)
  List<AppUsageInfo> _appUsageList = [];
  List<AppUsageInfo> get appUsageList => _appUsageList;

  // Para os dados agregados que sua tela do Canvas espera
  Map<String, dynamic>? _statisticData;
  Map<String, dynamic>? get statisticData => _statisticData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error; // Mudado de _errorMessage para _error para corresponder à sua tela
  String? get error => _error;

  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  StatisticViewModel({required UsageRepository usageRepository}) : _usageRepository = usageRepository;

  // Método para carregar os dados combinados
  Future<void> loadAllStatisticData(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Verificar e solicitar permissão de uso do dispositivo (para AppUsageInfo)
      _permissionGranted = await _usageRepository.checkUsageStatsPermission();
      if (!_permissionGranted) {
        bool permissionRequested = await _usageRepository.requestUsageStatsPermission();
        if (permissionRequested) {
          // Tenta verificar novamente após o usuário interagir com as configurações
          await Future.delayed(const Duration(milliseconds: 500)); // Pequeno delay
          _permissionGranted = await _usageRepository.checkUsageStatsPermission();
        }
      }

      if (!_permissionGranted) {
        _error = "Permissão de acesso ao uso do dispositivo é necessária.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Carregar a lista de apps (opcional, se você for usar em algum lugar)
      // _appUsageList = await _usageRepository.getAppUsageStats();

      // 3. Carregar os dados agregados do seu StatisticService
      // O StatisticService já usa UsageRepository.getTodayUsage, que agora pega os dados do dispositivo.
      _statisticData = await _statisticService.getStatisticData(
        userId,
        DateTime.now().toIso8601String().split('T')[0],
      );

      // Se _statisticData['totalTime'] (tempo de uso do celular) precisar ser preenchido
      // diretamente da soma dos AppUsageInfo, você pode fazer isso aqui também.
      // No entanto, o UsageRepositoryImpl.getTodayUsage já faz essa soma.
      // Então, _statisticService.getStatisticData já deve conter o 'totalTime' correto.

    } catch (e) {
      _error = e.toString();
      print("Erro no StatisticViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Métodos antigos (se você quiser manter a funcionalidade de carregar apenas a lista de apps separadamente)
// Ou você pode remover/adaptá-los.
// Por ora, vou manter o foco no loadAllStatisticData.

// Future<void> checkPermissionAndLoadAppList() async {
//   _isLoading = true;
//   _error = null;
//   notifyListeners();

//   _permissionGranted = await _usageRepository.checkUsageStatsPermission();
//   if (_permissionGranted) {
//     await fetchAppListUsageStats();
//   } else {
//     _error = "Permissão de acesso ao uso não concedida. Por favor, conceda a permissão.";
//   }
//   _isLoading = false;
//   notifyListeners();
// }

// Future<void> requestDeviceUsagePermission() async {
//   _isLoading = true;
//   notifyListeners();
//   bool requested = await _usageRepository.requestUsageStatsPermission();
//   if (requested) {
//     await Future.delayed(const Duration(seconds: 1));
//     await checkPermissionAndLoadAppList();
//   } else {
//     _error = "Não foi possível abrir as configurações de permissão.";
//     _isLoading = false;
//     notifyListeners();
//   }
// }

// Future<void> fetchAppListUsageStats() async {
//   // ... lógica para buscar apenas _appUsageList ...
// }
}