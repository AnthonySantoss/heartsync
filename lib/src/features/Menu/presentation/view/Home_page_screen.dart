import 'dart:io';
import 'package:flutter/material.dart';
import 'package:heartsync/servico/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/servico/StatisticService.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:heartsync/domain/entities/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StatisticService _statisticService = GetIt.instance<StatisticService>();
  final DatabaseHelper _databaseHelper = GetIt.instance<DatabaseHelper>();
  final ApiService _apiService = GetIt.instance<ApiService>();

  User? user;
  String usageTime = '0h00min';
  String userRemainingTime = '0h00min';
  String nextRouletteTime = '4h20min';
  String lastRouletteActivity = 'Cinema 🍿';
  int streakCount = 0;
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('HomePage: initState chamado');
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      print('HomePage: Iniciando carregamento de dados');

      final isLoggedIn = await AuthManager.isLoggedIn();
      print('HomePage: Resultado de AuthManager.isLoggedIn(): $isLoggedIn');
      if (!isLoggedIn) {
        print('HomePage: Usuário não está logado, redirecionando para /login');
        await _logout(context);
        return;
      }

      final userId = await AuthManager.getLocalId();
      print('HomePage: localId obtido: $userId');
      if (userId == null) {
        print('HomePage: localId é nulo, redirecionando para /login');
        await _logout(context);
        return;
      }

      final users = await _databaseHelper.getUsuarios();
      print('HomePage: Usuários encontrados no banco: $users');
      final userData = users.firstWhere(
            (u) => u['id'] == userId,
        orElse: () => throw Exception('Usuário não encontrado no banco de dados'),
      );
      user = User.fromDbMap(userData);
      print('HomePage: Usuário carregado: ${user!.name}');

      final stats = await _statisticService.getStatisticData(
        userId,
        DateTime.now().toIso8601String().split('T')[0],
      );
      print('HomePage: Dados estatísticos obtidos: $stats');

      final recados = await _databaseHelper.getRecados(userId);
      print('HomePage: Recados obtidos: $recados');

      final rouletteData = await _databaseHelper.getLatestRoulette(userId);
      print('HomePage: Dados da roleta obtidos: $rouletteData');

      final currentStreak = await _handleStreakLogic(userId, rouletteData);
      print('HomePage: Streak atual: $currentStreak');

      nextRouletteTime = await _calculateNextRouletteTime(rouletteData);
      print('HomePage: nextRouletteTime calculado: $nextRouletteTime');

      setState(() {
        usageTime = stats['totalTime'] ?? '0h00min';
        userRemainingTime = stats['remainingTime'] ?? '0h00min';
        messages = recados.map((r) => {
          'text': r['texto'],
          'time': r['dataHora'],
          'isOther': r['isOther'] == 1,
        }).toList();
        streakCount = currentStreak;
        if (rouletteData != null) {
          lastRouletteActivity = rouletteData['atividade'] ?? 'Cinema 🍿';
        }
        isLoading = false;
      });
      print('HomePage: Dados carregados com sucesso');
    } catch (e, stackTrace) {
      print('HomePage: Erro ao carregar dados: $e');
      print('HomePage: StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: ${e.toString()}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<int> _handleStreakLogic(int userId, Map<String, dynamic>? rouletteData) async {
    try {
      int currentStreak = await _databaseHelper.getStreakCount(userId) ?? 0;
      final lastStreakDate = await _databaseHelper.getLastStreakDate(userId);
      print('HomePage: Streak atual: $currentStreak, Última data de streak: $lastStreakDate');

      final today = DateTime.now().toLocal();
      final todayString = today.toIso8601String().split('T')[0];

      dynamic serverStreakData = await _apiService.getStreak(userId);
      int serverStreak = 0;
      String? serverLastStreakDate;
      if (serverStreakData is Map<String, dynamic>) {
        serverStreak = serverStreakData['streak'] ?? 0;
        serverLastStreakDate = serverStreakData['lastStreakDate'];
      }
      print('HomePage: Streak do servidor: $serverStreak, Última data do servidor: $serverLastStreakDate');

      if (serverStreak > currentStreak) {
        currentStreak = serverStreak;
        await _databaseHelper.updateStreakCount(userId, currentStreak, lastStreakDate: serverLastStreakDate);
        print('HomePage: Streak local atualizado com valor do servidor: $currentStreak');
      }

      if (rouletteData == null || rouletteData['dataRoleta'] == null) {
        if (lastStreakDate != null) {
          final lastDate = DateTime.parse(lastStreakDate).toLocal();
          final difference = today.difference(lastDate).inDays;
          if (difference > 1) {
            print('HomePage: Streak expirado, resetando');
            await _resetStreak(userId);
            return 0;
          }
        }
        return currentStreak;
      }

      final lastRouletteDate = DateTime.parse(rouletteData['dataRoleta']).toLocal();
      final difference = today.difference(lastRouletteDate).inDays;
      print('HomePage: Última data de roleta: $lastRouletteDate, Diferença de dias: $difference');

      if (difference == 0) {
        print('HomePage: Giro realizado hoje, mantendo streak: $currentStreak');
        return currentStreak;
      } else if (difference == 1) {
        print('HomePage: Giro realizado ontem, incrementando streak');
        currentStreak++;
        // Corrected line: Pass lastStreakDate as a named argument
        await _databaseHelper.updateStreakCount(userId, currentStreak, lastStreakDate: todayString);
        await _apiService.updateStreak(userId, currentStreak, lastStreakDate: todayString); // Fixed here
        return currentStreak;
      } else {
        print('HomePage: Streak expirado, resetando');
        await _resetStreak(userId);
        return 0;
      }
    } catch (e, stackTrace) {
      print('HomePage: Erro ao verificar streak: $e');
      print('HomePage: StackTrace: $stackTrace');
      return 0;
    }
  }

  Future<String> _calculateNextRouletteTime(Map<String, dynamic>? rouletteData) async {
    try {
      const defaultDuration = Duration(hours: 4); // Duração padrão do cronômetro: 4 horas
      if (rouletteData != null && rouletteData['proximaRoleta'] != null) {
        final nextRoulette = DateTime.parse(rouletteData['proximaRoleta']).toLocal();
        final now = DateTime.now().toLocal();
        if (nextRoulette.isAfter(now)) {
          final remaining = nextRoulette.difference(now);
          final hours = remaining.inHours.toString().padLeft(2, '0');
          final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
          return '$hours:$minutes:$seconds';
        }
      }
      final next = DateTime.now().toLocal().add(defaultDuration);
      final hours = next.hour.toString().padLeft(2, '0');
      final minutes = next.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    } catch (e, stackTrace) {
      print('HomePage: Erro ao calcular nextRouletteTime: $e');
      print('HomePage: StackTrace: $stackTrace');
      return '00:00';
    }
  }

  Future<void> _resetStreak(int userId) async {
    try {
      print('HomePage: Resetando streak para userId: $userId');
      await _databaseHelper.updateStreakCount(userId, 0, lastStreakDate: null);
      await _apiService.resetStreak(userId);
      print('HomePage: Streak resetado com sucesso');
    } catch (e, stackTrace) {
      print('HomePage: Erro ao resetar streak: $e');
      print('HomePage: StackTrace: $stackTrace');
      throw Exception('Falha ao resetar streak');
    }
  }

  Future<void> _logout(BuildContext context) async {
    print('HomePage: Iniciando logout');
    await AuthManager.clearSession();
    print('HomePage: Sessão limpa, navegando para /login');
    await Navigator.pushReplacementNamed(context, '/login');
    print('HomePage: Navegação para /login concluída');
  }

  @override
  Widget build(BuildContext context) {
    print('HomePage: Construindo widget');
    if (isLoading || user == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF170D2E),
                Color(0xFF010101),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF170D2E),
              Color(0xFF010101),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                const Text(
                  'Hoje',
                  style: TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildUsageCard(context),
                const SizedBox(height: 20),
                _buildMidCards(context),
                const SizedBox(height: 20),
                _buildRecadosList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Container()),
        Image.asset('lib/assets/images/logo.png', width: 52),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                print('HomePage: Navegando para /profile');
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {
                    'userName': user!.name,
                    'birthDate': user!.birthDate != null
                        ? DateFormat('dd.MM.yyyy').format(user!.birthDate!)
                        : 'Não definido',
                    'anniversaryDate': user!.anniversaryDate != null
                        ? DateFormat('dd.MM.yyyy').format(user!.anniversaryDate!)
                        : 'Não definido',
                    'syncDate': user!.syncDate != null
                        ? DateFormat('dd.MM.yyyy').format(user!.syncDate!)
                        : 'Não definido',
                    'imageUrl': user!.photoUrl,
                  },
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user!.photoUrl != null && user!.photoUrl!.isNotEmpty
                    ? (user!.photoUrl!.startsWith('http')
                    ? NetworkImage(user!.photoUrl!)
                    : FileImage(File(user!.photoUrl!))) as ImageProvider
                    : const NetworkImage('https://via.placeholder.com/150'),
                onBackgroundImageError: (exception, stackTrace) {
                  print('HomePage: Erro ao carregar imagem de perfil: $exception');
                },
                child: user!.photoUrl == null || user!.photoUrl!.isEmpty
                    ? const Icon(Icons.person, color: Colors.black)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print('HomePage: Navegando para /statistics');
        final result = await Navigator.pushNamed(context, '/statistics');
        if (result == true && mounted) {
          print('HomePage: Retornou da StatisticScreen com sucesso, recarregando dados...');
          _loadData();
        } else {
          print('HomePage: Retornou da StatisticScreen, resultado: $result');
        }
      },
      child: Container(
        width: 423,
        height: 272,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
        ),
        child: Column(
          children: [
            const Text(
              'Tempo de uso',
              style: TextStyle(
                color: Color(0xFFD9D9D9),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  user!.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usageTime,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                const Text(
                  'Seu tempo restante',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userRemainingTime,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMidCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              print('HomePage: Navegando para /roulette');
              final result = await Navigator.pushNamed(context, '/roulette');
              if (result == true && mounted) {
                print('HomePage: Retornou da RouletteScreen com sucesso, recarregando dados...');
                _loadData();
              }
            },
            child: Container(
              width: 280,
              height: 146,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF210E45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    textAlign: TextAlign.center,
                    'Roleta 🎡',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Próxima Roleta',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextRouletteTime,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Última Atividade',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastRouletteActivity,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 130,
          height: 146,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFBA9513), Color(0xFF961200)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Série',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/images/sequencia.png',
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                      streakCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecadosList() {
    return Expanded(
      child: Container(
        width: 425,
        height: 222,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF210E45),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recados',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildRecado(
                    message['text'],
                    message['time'],
                    isOther: message['isOther'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecado(String text, String time, {bool isOther = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            child: const Icon(Icons.person, color: Colors.black),
            backgroundColor: Colors.white,
            radius: 15,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            DateFormat('HH:mm').format(DateTime.parse(time)),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}