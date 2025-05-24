import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/domain/repositories/usage_repository.dart';
import 'package:get_it/get_it.dart';

class StatisticService {
  final DatabaseHelper _dbHelper;
  final UsageRepository _usageRepository;

  StatisticService(this._dbHelper) : _usageRepository = GetIt.instance<UsageRepository>();

  Future<Map<String, dynamic>> getStatisticData(int userId, String dataUso) async {
    try {
      final usuario = (await _dbHelper.getUsuarios())
          .firstWhere((u) => u['id'] == userId, orElse: () => throw Exception('Usuário não encontrado'));

      // Obter tempo de uso real do dispositivo via UsageRepository
      final double usageHours = await _usageRepository.getTodayUsage(userId);
      print('StatisticService: Tempo de uso (horas) retornado por UsageRepository: $usageHours');
      final int tempoUsado = (usageHours.isNaN || usageHours <= 0) ? 0 : (usageHours * 60).toInt();
      print('StatisticService: Tempo de uso convertido (minutos): $tempoUsado');

      // Obter limite de uso
      final double limitHours = await _usageRepository.getUsageLimit(userId);
      print('StatisticService: Limite de uso (horas) retornado por UsageRepository: $limitHours');
      final int metaUso = (limitHours.isNaN || limitHours <= 0) ? 120 : (limitHours * 60).toInt(); // Default 2h se inválido
      print('StatisticService: Meta de uso convertida (minutos): $metaUso');

      await _updateUsoCelular(userId, dataUso, metaUso, tempoUsado);

      final tempoRestante = await _dbHelper.getTempoRestante(userId, dataUso);
      final usoSemanal = await _dbHelper.getUsoCelularUltimaSemana(userId);
      final mediaSemanal = await _dbHelper.getMediaSemanal(userId);

      final usageData = List<double>.generate(7, (index) {
        final data = DateTime.now().subtract(Duration(days: 6 - index)).toIso8601String().split('T')[0];
        final dailyEntry = usoSemanal.firstWhere(
              (u) => u['dataUso'] == data,
          orElse: () => {'tempoUsadoEmMinutos': 0},
        );
        return (dailyEntry['tempoUsadoEmMinutos'] ?? 0).toDouble() / 60; // Horas
      });

      final diasUsados = usoSemanal.length;

      return {
        'userName': usuario['nome'] ?? 'Usuário',
        'imageUrl': usuario['temFoto'] == 1 ? usuario['profileImagePath'] ?? 'URL_DA_FOTO' : null,
        'remainingTime': formatMinutes(tempoRestante['tempoRestante'] ?? 0),
        'totalTime': formatMinutes(tempoRestante['tempoUsado'] ?? tempoUsado), // Usar tempoUsado diretamente se nulo
        'usageData': usageData,
        'dailyTimeLimit': formatMinutes(tempoRestante['metaUso'] ?? metaUso), // Usar metaUso diretamente se nulo
        'timeLimitRange': '00:00 – 24:00',
        'weeklyAverage': '${mediaSemanal.toStringAsFixed(0)} min',
        'dayUsed': diasUsados.toString(),
      };
    } catch (e) {
      print('Erro ao obter dados estatísticos: $e');
      throw Exception('Falha ao carregar dados estatísticos: $e');
    }
  }

  Future<void> _updateUsoCelular(int userId, String dataUso, int metaUso, int tempoUsado) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'uso_celular',
      where: 'idUsuario = ? AND dataUso = ?',
      whereArgs: [userId, dataUso],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      await db.update(
        'uso_celular',
        {
          'tempoUsadoEmMinutos': tempoUsado,
          'metaUso': metaUso,
        },
        where: 'idUsuario = ? AND dataUso = ?',
        whereArgs: [userId, dataUso],
      );
    } else {
      await _dbHelper.insertUsoCelular(
        idUsuario: userId,
        dataUso: dataUso,
        tempoUsadoEmMinutos: tempoUsado,
        metaUso: metaUso,
      );
    }
  }

  String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h${mins.toString().padLeft(2, '0')}min';
  }
}