import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart'; // Verifique o caminho
import 'package:fl_chart/fl_chart.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/presentation/viewmodels/statistic_viewmodel.dart';
import 'package:intl/intl.dart'; // Para formatar os dias da semana
import 'package:permission_handler/permission_handler.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final localId = await AuthManager.getLocalId();
    if (!mounted) return;

    if (localId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado. Por favor, faça login novamente.')),
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return;
    }
    setState(() {
      _userId = localId;
    });

    Provider.of<StatisticViewModel>(context, listen: false).loadAllStatisticData(_userId!);
  }

  String _getDayAbbreviation(int dayIndexFromEnd) {
    final DateTime day = DateTime.now().subtract(Duration(days: dayIndexFromEnd));
    return DateFormat('E', 'pt_BR').format(day);
  }

  // Função para determinar o valor de retorno ao sair da tela
  bool _getNavigationResult(StatisticViewModel viewModel) {
    final bool success = viewModel.statisticData != null && viewModel.error == null && viewModel.permissionGranted;
    print('StatisticScreen: Determinando resultado da navegação: $success');
    return success;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StatisticViewModel>(context);

    if (viewModel.isLoading || _userId == null) {
      return const Scaffold(
        body: BackgroundWidget(
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    if (!viewModel.permissionGranted && viewModel.error != null && viewModel.error!.contains("Permissão")) {
      // Tela para solicitar permissão
      return Scaffold(
        // Adicionando um AppBar simples para o botão de voltar, mantendo a estética.
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Image.asset('lib/assets/images/Back.png', width: 27, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, false); // Retorna false pois a permissão não foi concedida
            },
          ),
        ),
        body: BackgroundWidget(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.orangeAccent, size: 50),
                  const SizedBox(height: 15),
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF972F6A),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        textStyle: const TextStyle(fontSize: 15)
                    ),
                    onPressed: () {
                      // loadAllStatisticData no ViewModel deve lidar com a tentativa de permissão
                      if (_userId != null) {
                        viewModel.loadAllStatisticData(_userId!);
                      }
                    },
                    child: const Text('Conceder Permissão / Tentar Novamente', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Você poderá ser redirecionado para as configurações do sistema.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (viewModel.error != null) {
      // Tela de erro geral
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Image.asset('lib/assets/images/Back.png', width: 27, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, false); // Retorna false devido ao erro
            },
          ),
        ),
        body: BackgroundWidget(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 15),
                  Text(
                    "Erro ao carregar dados: ${viewModel.error!}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF972F6A),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        textStyle: const TextStyle(fontSize: 15)
                    ),
                    onPressed: () {
                      if (_userId != null) {
                        viewModel.loadAllStatisticData(_userId!);
                      }
                    },
                    child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final statisticData = viewModel.statisticData;
    if (statisticData == null) {
      // Tela de dados nulos
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Image.asset('lib/assets/images/Back.png', width: 27, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, false); // Retorna false pois não há dados
            },
          ),
        ),
        body: BackgroundWidget(
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhum dado disponível. Tente atualizar.', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF972F6A),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        textStyle: const TextStyle(fontSize: 15)
                    ),
                    onPressed: () {
                      if (_userId != null) {
                        viewModel.loadAllStatisticData(_userId!);
                      }
                    },
                    child: const Text('Atualizar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
          ),
        ),
      );
    }

    final List<double> weeklyUsageHours = (statisticData['usageData'] as List<dynamic>?)
        ?.map((e) => (e as num).toDouble())
        .toList() ?? List.filled(7, 0.0);

    double maxYGraph = 3.0;
    if (weeklyUsageHours.isNotEmpty) {
      maxYGraph = weeklyUsageHours.fold(0.0, (max, current) => current > max ? current : max); // Corrigido para evitar erro com lista vazia
      if (maxYGraph < 3.0) {
        maxYGraph = 3.0;
      } else {
        maxYGraph = (maxYGraph * 1.2).ceilToDouble();
      }
    }

    // Envolve o Scaffold principal com WillPopScope
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _getNavigationResult(viewModel));
        return false;
      },
      child: Scaffold(
        // Não há AppBar explícito aqui no seu código original para o estado de sucesso,
        // o botão de voltar está no corpo.
        body: BackgroundWidget(
          padding: const EdgeInsets.all(0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 20, right: 20, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          // MODIFICADO: Chama _getNavigationResult
                          onPressed: () => Navigator.pop(context, _getNavigationResult(viewModel)),
                          icon: Image.asset(
                            'lib/assets/images/Back.png',
                            width: 27,
                            color: Colors.white, // Adicionado cor para melhor visibilidade no fundo escuro
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'lib/assets/images/sequencia.png',
                                  width: 24,
                                  height: 31,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  statisticData['dayUsed']?.toString() ?? '0',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFDBDBDB),
                            backgroundImage: statisticData['imageUrl'] != null && (statisticData['imageUrl'] as String).isNotEmpty
                                ? NetworkImage(statisticData['imageUrl'])
                                : null,
                            child: statisticData['imageUrl'] == null || (statisticData['imageUrl'] as String).isEmpty
                                ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Color(0xFF210E45),
                            )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFB02D78),
                            Color(0xFF230640),
                            Color(0xFF015021),
                          ],
                          stops: [0.0, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            statisticData['userName'] ?? 'Usuário',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            statisticData['remainingTime'] ?? '0h0min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Tempo restante',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.white30),
                          const SizedBox(height: 10),
                          const Text(
                            'Tempo total de uso hoje:',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statisticData['totalTime'] ?? '0h0min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 220,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF210E45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uso Semanal',
                            style: TextStyle(
                              color: Color(0xFFB4B4B4),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxYGraph,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (group) => Colors.grey.shade800, // Ajustado para melhor visibilidade
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      String day = _getDayAbbreviation(6 - group.x.toInt());
                                      return BarTooltipItem(
                                        '$day\n',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: '${rod.toY.toStringAsFixed(1)} h',
                                            style: const TextStyle(
                                              color: Colors.yellowAccent, // Ajustado para melhor visibilidade
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 35,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0 && maxYGraph > 0) return const Text(''); // Evita sobreposição do 0h
                                        // Ajusta o intervalo para não ficar muito poluído
                                        double interval = (maxYGraph / 4).ceilToDouble();
                                        if (interval == 0) interval = 1; // Evita divisão por zero ou intervalo zero
                                        if (value % interval == 0 || value == maxYGraph) {
                                          return Text('${value.toInt()}h', style: const TextStyle(color: Colors.white70, fontSize: 10));
                                        }
                                        return const Text('');
                                      },
                                      interval: (maxYGraph / 4).ceilToDouble() == 0 ? 1 : (maxYGraph / 4).ceilToDouble(),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(_getDayAbbreviation(6 - value.toInt()), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                        );
                                      },
                                      interval: 1,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                    show: true,
                                    border: Border(
                                      bottom: BorderSide(color: Colors.white24, width: 1),
                                      left: BorderSide(color: Colors.white24, width: 1),
                                    )
                                ),
                                barGroups: weeklyUsageHours
                                    .asMap()
                                    .map((index, hours) => MapEntry(
                                    index,
                                    BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                            toY: hours,
                                            color: const Color(0xFF972F6A),
                                            width: 18,
                                            borderRadius: BorderRadius.circular(4)
                                        ),
                                      ],
                                    )))
                                    .values
                                    .toList(),
                                gridData: FlGridData( // Linhas de grade horizontais
                                  show: true,
                                  drawVerticalLine: false, // Não mostrar linhas verticais
                                  horizontalInterval: (maxYGraph / 4).ceilToDouble() == 0 ? 1 : (maxYGraph / 4).ceilToDouble(),
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.white10, // Cor suave para a grade
                                      strokeWidth: 0.8,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaça os containers uniformemente
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF210E45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Tempo diário definido',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              statisticData['dailyTimeLimit'] ?? 'N/A',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Horário limite:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statisticData['timeLimitRange'] ?? 'N/A',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Espaço entre os containers
                    Expanded(
                      child: Container(
                        width: 192,
                        height: 174,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF210E45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Média semanal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              statisticData['weeklyAverage'] ?? '0 min',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

