import 'package:flutter/material.dart';
import 'package:heartsync/servico/StatisticService.dart';
import 'package:heartsync/servico/device_usage.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:fl_chart/fl_chart.dart';


class StatisticScreen extends StatefulWidget {
  final String codigoConexao;

  const StatisticScreen({super.key, required this.codigoConexao});

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final StatisticService _statisticService = StatisticService();
  Map<String, dynamic>? _statisticData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
    _loadData();
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _statisticService.getStatisticData(
        widget.codigoConexao,
        DateTime.now().toIso8601String().split('T')[0],
      );
      setState(() {
        _statisticData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
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
                              _statisticData!['dayUsed'],
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
                        backgroundImage: _statisticData!['imageUrl'] != null
                            ? NetworkImage(_statisticData!['imageUrl'])
                            : null,
                        child: _statisticData!['imageUrl'] == null
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
                child: Row(
                  children: [
                    Expanded(
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
                              _statisticData!['userName1'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _statisticData!['remainingTime1'],
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
                              _statisticData!['totalTime1'],
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C6E3E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _statisticData!['userName2'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _statisticData!['remainingTime2'],
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
                              _statisticData!['totalTime2'],
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
                  ],
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
                                spots: (_statisticData!['usageData1'] as List<double>)
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
                              LineChartBarData(
                                spots: (_statisticData!['usageData2'] as List<double>)
                                    .asMap()
                                    .entries
                                    .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                                    .toList(),
                                isCurved: true,
                                color: const Color(0xFF4BBE79),
                                barWidth: 2,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF4BBE79).withOpacity(0.2),
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
                            _statisticData!['dailyTimeLimit'],
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
                                _statisticData!['timeLimitRange'],
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
                            'Média da semanal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _statisticData!['weeklyAverage'],
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
  }
}