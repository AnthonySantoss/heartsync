import 'package:heartsync/data/datasources/database_helper.dart';
// O import de device_usage.dart foi removido pois não era usado diretamente aqui
// e as funcionalidades de device usage agora são acessadas via UsageRepository.
import 'package:heartsync/domain/repositories/usage_repository.dart';
import 'package:get_it/get_it.dart';

class StatisticService {
  final DatabaseHelper _dbHelper;
  final UsageRepository _usageRepository;

  // Construtor modificado para injetar UsageRepository explicitamente,
  // embora buscar via GetIt.instance no construtor também funcione se já registrado.
  // Para melhor testabilidade e clareza, a injeção via construtor é preferível
  // quando o DI é configurado para passar a instância.
  // Se você registrou StatisticService com GetIt passando _dbHelper,
  // e quer que _usageRepository seja resolvido por GetIt, a forma original está OK.
  // Vou manter a forma original para consistência com o código fornecido.
  StatisticService(this._dbHelper) : _usageRepository = GetIt.instance<UsageRepository>();

  // Alternativa com injeção explícita (requer mudança no DI para StatisticService):
  // StatisticService({required DatabaseHelper dbHelper, required UsageRepository usageRepository})
  //     : _dbHelper = dbHelper,
  //       _usageRepository = usageRepository;


  Future<Map<String, dynamic>> getStatisticData(int userId, String dataUso) async {
    try {
      final usuario = (await _dbHelper.getUsuarios())
          .firstWhere((u) => u['id'] == userId, orElse: () => throw Exception('Usuário não encontrado'));

      // Obter tempo de uso real do dispositivo via UsageRepository (espera-se que retorne horas)
      final double usageHours = await _usageRepository.getTodayUsage(userId);
      final int tempoUsado = (usageHours * 60).toInt(); // Converter horas para minutos

      // Obter limite de uso (espera-se que retorne horas)
      final double limitHours = await _usageRepository.getUsageLimit(userId);
      final int metaUso = (limitHours * 60).toInt(); // Converter horas para minutos

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
        'totalTime': formatMinutes(tempoRestante['tempoUsado'] ?? 0),
        'usageData': usageData,
        'dailyTimeLimit': formatMinutes(tempoRestante['metaUso'] ?? 0),
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