import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/servico/device_usage.dart';

class StatisticService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getStatisticData(String codigoConexao, String dataUso) async {
    final casal = await _dbHelper.getCasalPorCodigo(codigoConexao);
    if (casal == null) {
      throw Exception('Casal não encontrado');
    }

    final idUsuario1 = casal['idUsuario1'] as int;
    final idUsuario2 = casal['idUsuario2'] as int;

    final usuarios = await _dbHelper.getUsuarios();
    final usuario1 = usuarios.firstWhere((u) => u['id'] == idUsuario1, orElse: () => {});
    final usuario2 = usuarios.firstWhere((u) => u['id'] == idUsuario2, orElse: () => {});

    // Obter tempo de uso real do dispositivo (apenas para o dispositivo atual)
    final tempoUsado1 = await DeviceUsage.getDeviceUsageTimeWithPermission();
    // Para o segundo usuário, assumir que os dados virão de um backend remoto (placeholder)
    // TODO: Implementar sincronização com backend para obter tempoUsado2
    const tempoUsado2 = 0; // Placeholder: deve ser substituído por chamada ao backend

    // Atualizar o banco com os tempos de uso, evitando duplicatas
    const metaUso = 240; // 4 horas em minutos (ajustar conforme necessário)
    await _updateUsoCelular(idUsuario1, dataUso, metaUso, tempoUsado1);
    await _updateUsoCelular(idUsuario2, dataUso, metaUso, tempoUsado2);

    final tempoRestante1 = await _dbHelper.getTempoRestante(idUsuario1, dataUso);
    final tempoRestante2 = await _dbHelper.getTempoRestante(idUsuario2, dataUso);

    final usoSemanal1 = await _dbHelper.getUsoCelularUltimaSemana(idUsuario1);
    final usoSemanal2 = await _dbHelper.getUsoCelularUltimaSemana(idUsuario2);

    final mediaSemanal1 = await _dbHelper.getMediaSemanal(idUsuario1);
    final mediaSemanal2 = await _dbHelper.getMediaSemanal(idUsuario2);
    final mediaSemanal = ((mediaSemanal1 + mediaSemanal2) / 2).toStringAsFixed(0);

    final List<double> usageData1 = List.generate(7, (index) {
      final data = DateTime.now().subtract(Duration(days: 6 - index)).toIso8601String().split('T')[0];
      return usoSemanal1.firstWhere(
            (u) => u['dataUso'] == data,
        orElse: () => {'tempoUsadoEmMinutos': 0},
      )['tempoUsadoEmMinutos'].toDouble() / 60;
    });

    final List<double> usageData2 = List.generate(7, (index) {
      final data = DateTime.now().subtract(Duration(days: 6 - index)).toIso8601String().split('T')[0];
      return usoSemanal2.firstWhere(
            (u) => u['dataUso'] == data,
        orElse: () => {'tempoUsadoEmMinutos': 0},
      )['tempoUsadoEmMinutos'].toDouble() / 60;
    });

    final diasUsados = usoSemanal1.length;

    return {
      'userName1': usuario1['nome'] ?? 'Usuário 1',
      'imageUrl': usuario1['temFoto'] == 1 ? usuario1['profileImagePath'] ?? 'URL_DA_FOTO' : null,
      'remainingTime1': formatMinutes(tempoRestante1['tempoRestante']),
      'totalTime1': formatMinutes(tempoRestante1['tempoUsado']),
      'userName2': usuario2['nome'] ?? 'Usuário 2',
      'remainingTime2': formatMinutes(tempoRestante2['tempoRestante']),
      'totalTime2': formatMinutes(tempoRestante2['tempoUsado']),
      'usageData1': usageData1,
      'usageData2': usageData2,
      'dailyTimeLimit': formatMinutes(tempoRestante1['metaUso']),
      'timeLimitRange': '00:00 – 24:00', // Ajustar conforme necessário
      'weeklyAverage': '$mediaSemanal min',
      'dayUsed': diasUsados.toString(),
    };
  }

  Future<void> _updateUsoCelular(int idUsuario, String dataUso, int metaUso, int tempoUsado) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'uso_celular',
      where: 'idUsuario = ? AND dataUso = ?',
      whereArgs: [idUsuario, dataUso],
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
        whereArgs: [idUsuario, dataUso],
      );
    } else {
      await _dbHelper.insertUsoCelular(
        idUsuario: idUsuario,
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