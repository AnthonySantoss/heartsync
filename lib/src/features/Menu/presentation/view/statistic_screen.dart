import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heartsync/servico/device_usage.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/presentation/viewmodels/statistic_viewmodel.dart';
import 'package:get_it/get_it.dart';

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
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _userId = await AuthManager.getLocalId();
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado. Por favor, faça login novamente.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _checkAndRequestPermission();
    // O carregamento de dados será feito pelo ViewModel
    Provider.of<StatisticViewModel>(context, listen: false).loadStatisticData(_userId!);
  }

  Future<void> _checkAndRequestPermission() async {
    final hasPermission = await DeviceUsage.checkUsagePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, conceda a permissão de acesso ao uso do dispositivo.')),
      );
      await DeviceUsage.requestUsagePermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.instance<StatisticViewModel>(),
      child: Consumer<StatisticViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.error!),
                    ElevatedButton(
                      onPressed: () => viewModel.loadStatisticData(_userId!),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final statisticData = viewModel.statisticData;
          if (statisticData == null) {
            return const Scaffold(
              body: Center(child: Text('Nenhum dado disponível')),
            );
          }

          return Scaffold(
            body: BackgroundWidget(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0, left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Image.asset(
                              'lib/assets/images/Back.png',
                              width: 27,
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
                                    statisticData['dayUsed'],
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfileScreen()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFDBDBDB),
                              backgroundImage: statisticData['imageUrl'] != null
                                  ? NetworkImage(statisticData['imageUrl'])
                                  : null,
                              child: statisticData['imageUrl'] == null
                                  ? const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF972F6A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              statisticData['userName'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              statisticData['remainingTime'],
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
                            const SizedBox(height: 5),
                            Text(
                              statisticData['totalTime'],
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
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF210E45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Limite',
                              style: TextStyle(
                                color: Color(0xFFB4B4B4),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          switch (value.toInt()) {
                                            case 0:
                                              return const Text('0', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 1:
                                              return const Text('1h', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 2:
                                              return const Text('2h', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 3:
                                              return const Text('3h', style: TextStyle(color: Colors.white, fontSize: 12));
                                            default:
                                              return const Text('');
                                          }
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          switch (value.toInt()) {
                                            case 0:
                                              return const Text('Dom', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 1:
                                              return const Text('Seg', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 2:
                                              return const Text('Ter', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 3:
                                              return const Text('Qua', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 4:
                                              return const Text('Qui', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 5:
                                              return const Text('Sex', style: TextStyle(color: Colors.white, fontSize: 12));
                                            case 6:
                                              return const Text('Sáb', style: TextStyle(color: Colors.white, fontSize: 12));
                                            default:
                                              return const Text('');
                                          }
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: 6,
                                  minY: 0,
                                  maxY: 3,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: (statisticData['usageData'] as List<double>)
                                          .asMap()
                                          .entries
                                          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                                          .toList(),
                                      isCurved: true,
                                      color: const Color(0xFF972F6A),
                                      barWidth: 2,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(0xFF972F6A).withOpacity(0.2),
                                      ),
                                    ),
                                  ],
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
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
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
                                  statisticData['dailyTimeLimit'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Horário limite:',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      statisticData['timeLimitRange'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
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
                                  statisticData['weeklyAverage'],
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}