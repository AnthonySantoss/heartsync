import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Removido: import 'package:heartsync/servico/device_usage.dart'; // Permissão agora é via ViewModel/Repository
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart'; // Verifique se este caminho está correto
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart'; // Verifique o caminho
import 'package:fl_chart/fl_chart.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/presentation/viewmodels/statistic_viewmodel.dart';
// Removido: import 'package:get_it/get_it.dart'; // ViewModel será obtido via Provider

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  int? _userId;
  // Referência ao ViewModel obtida no build ou via Provider.of com listen:false
  // StatisticViewModel? _viewModel; // Opcional

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final localId = await AuthManager.getLocalId();
    if (!mounted) return; // Verifica se o widget ainda está na árvore

    if (localId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado. Por favor, faça login novamente.')),
      );
      // Atrasar um pouco a navegação para permitir que o SnackBar seja exibido
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

    // Chama o método do ViewModel para carregar todos os dados (incluindo verificação de permissão)
    // Usamos listen:false aqui porque estamos em initState
    Provider.of<StatisticViewModel>(context, listen: false).loadAllStatisticData(_userId!);
  }

  // A lógica de _checkAndRequestPermission foi movida para dentro do StatisticViewModel.loadAllStatisticData

  @override
  Widget build(BuildContext context) {
    // Obtém o ViewModel usando Provider. A UI vai reagir às mudanças nele.
    final viewModel = Provider.of<StatisticViewModel>(context);

    if (viewModel.isLoading || _userId == null) { // Adicionado _userId == null para aguardar _initializeData
      return const Scaffold(
        body: BackgroundWidget( // Mantendo o background durante o loading
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    // Lógica para quando a permissão não foi concedida (após a tentativa de carregamento)
    if (!viewModel.permissionGranted && viewModel.error != null && viewModel.error!.contains("Permissão")) {
      return Scaffold(
        body: BackgroundWidget(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF972F6A)),
                    onPressed: () {
                      // Tenta carregar novamente, o ViewModel lidará com a tentativa de permissão
                      viewModel.loadAllStatisticData(_userId!);
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
        body: BackgroundWidget(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Erro ao carregar dados: ${viewModel.error!}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF972F6A)),
                    onPressed: () => viewModel.loadAllStatisticData(_userId!),
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
      return const Scaffold(
        body: BackgroundWidget(
          child: Center(child: Text('Nenhum dado disponível. Tente atualizar.', style: TextStyle(color: Colors.white))),
        ),
      );
    }

    // A partir daqui, o resto da sua UI que usa statisticData
    // Não precisa do ChangeNotifierProvider.value aqui, pois já está sendo provido acima na árvore (main.dart)
    // e estamos usando Consumer ou Provider.of.
    return Scaffold(
      body: BackgroundWidget(
        padding: const EdgeInsets.all(0), // Seu padding original
        child: SafeArea( // Adicionado SafeArea para evitar sobreposição com status bar/notch
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 20, right: 20, bottom: 10), // Ajustado padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          'lib/assets/images/Back.png', // Certifique-se que este asset existe
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
                                'lib/assets/images/sequencia.png', // Certifique-se que este asset existe
                                width: 24,
                                height: 31,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statisticData['dayUsed']?.toString() ?? '0', // Adicionado ?.toString() e fallback
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
                          // Certifique-se que ProfileScreen existe e aceita estes argumentos ou está configurada para pegar via ViewModel
                          Navigator.pushNamed(context, '/profile');
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFDBDBDB),
                          backgroundImage: statisticData['imageUrl'] != null && (statisticData['imageUrl'] as String).isNotEmpty
                              ? NetworkImage(statisticData['imageUrl']) // Assumindo que é uma URL da web
                          // Se for um caminho de arquivo local: FileImage(File(statisticData['imageUrl']))
                              : null,
                          child: statisticData['imageUrl'] == null || (statisticData['imageUrl'] as String).isEmpty
                              ? const Icon(
                            Icons.person,
                            size: 30, // Ajustado
                            color: Color(0xFF210E45), // Cor de contraste
                          )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                // O restante da sua UI (cards, gráfico) continua aqui
                // usando os dados de `statisticData` como você já faz.
                // Exemplo:
                const SizedBox(height: 10), // Reduzido para mais espaço
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
                        const SizedBox(height: 10), // Aumentado para espaçamento
                        const Divider(color: Colors.white30), // Divisor opcional
                        const SizedBox(height: 10),
                        Text(
                          'Tempo total de uso hoje:', // Texto mais claro
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statisticData['totalTime'] ?? '0h0min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18, // Aumentado para destaque
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
                    height: 200, // Altura do gráfico
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Ajustado padding
                    decoration: BoxDecoration(
                      color: const Color(0xFF210E45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uso Semanal (horas)', // Título do Gráfico
                          style: TextStyle(
                            color: Color(0xFFB4B4B4),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15), // Aumentado para mais espaço
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
                                      if (value % 1 == 0 && value >= 0 && value <= (statisticData['maxYGraph'] ?? 3.0)) { // Ajusta para o maxY dinâmico
                                        return Text('${value.toInt()}h', style: const TextStyle(color: Colors.white, fontSize: 10));
                                      }
                                      return const Text('');
                                    },
                                    interval: 1, // Mostrar a cada 1 hora
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30, // Ajustado
                                    getTitlesWidget: (value, meta) {
                                      // Assumindo que os dados são de Dom a Sáb (0 a 6)
                                      const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
                                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(days[value.toInt()], style: const TextStyle(color: Colors.white, fontSize: 10)),
                                        );
                                      }
                                      return const Text('');
                                    },
                                    interval: 1,
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 6, // 7 dias (0 a 6)
                              minY: 0,
                              maxY: (statisticData['maxYGraph'] ?? 3.0).toDouble(), // Ajustar dinamicamente ou deixar um valor fixo
                              lineBarsData: [
                                LineChartBarData(
                                  spots: (statisticData['usageData'] as List<dynamic>) // Alterado para List<dynamic>
                                      .asMap()
                                      .entries
                                      .map((entry) => FlSpot(entry.key.toDouble(), (entry.value as num).toDouble())) // Cast para num e depois double
                                      .toList(),
                                  isCurved: true,
                                  color: const Color(0xFF972F6A),
                                  barWidth: 2.5, // Aumentado
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true), // Mostrar pontos
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient( // Gradiente mais suave
                                      colors: [
                                        const Color(0xFF972F6A).withOpacity(0.4),
                                        const Color(0xFF972F6A).withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
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
                              statisticData['dailyTimeLimit'] ?? 'N/A',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10), // Aumentado
                            const Text(
                              'Horário limite:', // Pode ser o "Modo Foco" ou similar
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
                              'Média semanal (uso)', // Texto mais claro
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
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Espaço no final
              ],
            ),
          ),
        ),
      ),
    );
  }
}
