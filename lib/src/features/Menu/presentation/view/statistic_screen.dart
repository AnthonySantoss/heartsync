import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticScreen extends StatelessWidget {
  final String userName1;
  final String? imageUrl;
  final String remainingTime1;
  final String totalTime1;
  final String userName2;
  final String remainingTime2;
  final String totalTime2;
  final List<double> usageData1;
  final List<double> usageData2;
  final String dailyTimeLimit;
  final String timeLimitRange;
  final String weeklyAverage;
  final String dayUsed;

  const StatisticScreen({
    super.key,
    this.userName1 = 'Isabela',
    this.imageUrl,
    this.remainingTime1 = '1h20min',
    this.totalTime1 = '2h40min',
    this.userName2 = 'Ricardo',
    this.remainingTime2 = '2h10min',
    this.totalTime2 = '1h50min',
    this.usageData1 = const [1.5, 2.0, 1.0, 2.5, 1.8, 1.2, 1.0],
    this.usageData2 = const [2.0, 1.0, 1.5, 1.8, 1.2, 1.0, 1.5],
    this.dailyTimeLimit = '4 horas',
    this.timeLimitRange = '00:00 – 4:00',
    this.weeklyAverage = '55 min',
    this.dayUsed = '3',
  });

  @override
  Widget build(BuildContext context) {
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
                              dayUsed,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
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
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl!)
                            : null,
                        child: imageUrl == null
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
                              userName1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              remainingTime1,
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
                              totalTime1,
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
                              userName2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              remainingTime2,
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
                              totalTime2,
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
                                      case 0: return const Text('0', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 1: return const Text('1h', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 2: return const Text('2h', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 3: return const Text('3h', style: TextStyle(color: Colors.white, fontSize: 12));
                                      default: return const Text('');
                                    }
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 0: return const Text('Dom', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 1: return const Text('Seg', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 2: return const Text('Ter', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 3: return const Text('Qua', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 4: return const Text('Qui', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 5: return const Text('Sex', style: TextStyle(color: Colors.white, fontSize: 12));
                                      case 6: return const Text('Sáb', style: TextStyle(color: Colors.white, fontSize: 12));
                                      default: return const Text('');
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
                                spots: usageData1.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), entry.value);
                                }).toList(),
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
                                spots: usageData2.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), entry.value);
                                }).toList(),
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
                      width: double.infinity, // Garante que ocupe a largura total disponível
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
                            dailyTimeLimit,
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
                                timeLimitRange,
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
                    const SizedBox(height: 20), // Espaçamento entre os containers
                    Container(
                      width: double.infinity, // Garante que ocupe a largura total disponível
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
                            weeklyAverage,
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