import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/presentation/viewmodels/statistic_viewmodel.dart';
import 'package:intl/intl.dart';
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
    return DateFormat('E', 'pt_BR').format(day).substring(0, 3); // Pega as primeiras 3 letras (Seg, Ter, etc.)
  }

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
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Image.asset('lib/assets/images/Back.png', width: 27, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, false);
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
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Image.asset('lib/assets/images/Back.png', width: 27, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, false);
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
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Image.asset('lib/assets/images/Back.png', width: 27, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, false);
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
      maxYGraph = weeklyUsageHours.fold(0.0, (max, current) => current > max ? current : max);
      if (maxYGraph < 3.0) {
        maxYGraph = 3.0;
      } else {
        maxYGraph = (maxYGraph * 1.2).ceilToDouble();
      }
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _getNavigationResult(viewModel));
        return false;
      },
      child: Scaffold(
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
                          onPressed: () => Navigator.pop(context, _getNavigationResult(viewModel)),
                          icon: Image.asset(
                            'lib/assets/images/Back.png',
                            width: 27,
                            color: Colors.white,
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
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.white10,
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: Colors.white10,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 22,
                                      getTitlesWidget: (value, meta) {
                                        const style = TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        );
                                        if (value >= 0 && value <= 6) { // Exibe os 7 dias (0 a 6)
                                          return Text(_getDayAbbreviation(6 - value.toInt()), style: style);
                                        }
                                        return const Text('');
                                      },
                                      interval: 1,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        const style = TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        );
                                        if (value == 0.5) {
                                          return const Text('30m', style: style);
                                        } else if (value == 1) {
                                          return const Text('1h', style: style);
                                        } else if (value == 2) {
                                          return const Text('2h', style: style);
                                        } else if (value == 3) {
                                          return const Text('3h', style: style);
                                        }
                                        return const Text('');
                                      },
                                      interval: 0.5,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.white10, width: 1),
                                ),
                                minX: 0,
                                maxX: 6, // Ajustado para 7 dias (0 a 6)
                                minY: 0,
                                maxY: 3,
                                lineBarsData: [
                                  // Linha de uso (rosa) baseada em weeklyUsageHours
                                  LineChartBarData(
                                    spots: weeklyUsageHours.asMap().entries.map((entry) {
                                      return FlSpot(entry.key.toDouble(), entry.value.clamp(0, 3)); // Limita valores a 0-3 horas
                                    }).toList(),
                                    isCurved: true,
                                    color: const Color(0xFFB02D78),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color(0xFFB02D78).withOpacity(0.3),
                                      applyCutOffY: true,
                                      cutOffY: 0,
                                    ),
                                    aboveBarData: BarAreaData(show: false),
                                  ),
                                ],
                                lineTouchData: LineTouchData(enabled: false),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const SizedBox(width: 20),
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