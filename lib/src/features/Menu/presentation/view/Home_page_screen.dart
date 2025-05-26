import 'dart:io';
import 'package:flutter/material.dart';
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

      print('HomePage: Verificando se o usuário está logado');
      final isLoggedIn = await AuthManager.isLoggedIn();
      print('HomePage: Resultado de AuthManager.isLoggedIn(): $isLoggedIn');
      if (!isLoggedIn) {
        print('HomePage: Usuário não está logado, redirecionando para /login');
        await _logout(context);
        return;
      }

      print('HomePage: Obtendo localId do AuthManager');
      final userId = await AuthManager.getLocalId();
      print('HomePage: localId obtido: $userId');
      if (userId == null) {
        print('HomePage: localId é nulo, redirecionando para /login');
        await _logout(context);
        return;
      }

      print('HomePage: Obtendo dados do usuário do banco');
      final users = await _databaseHelper.getUsuarios();
      print('HomePage: Usuários encontrados no banco: $users');
      final userData = users.firstWhere(
            (u) => u['id'] == userId,
        orElse: () => throw Exception('Usuário não encontrado no banco de dados'),
      );
      user = User.fromDbMap(userData);
      print('HomePage: Usuário carregado: ${user!.name}');

      print('HomePage: Obtendo dados estatísticos');
      final stats = await _statisticService.getStatisticData(
        userId,
        DateTime.now().toIso8601String().split('T')[0],
      );
      print('HomePage: Dados estatísticos obtidos: $stats');

      print('HomePage: Obtendo recados');
      final recados = await _databaseHelper.getRecados(userId);
      print('HomePage: Recados obtidos: $recados');

      print('HomePage: Obtendo streakCount');
      final streak = await _databaseHelper.getStreakCount(userId);
      print('HomePage: streakCount obtido: $streak');

      print('HomePage: Obtendo dados da roleta');
      final rouletteData = await _databaseHelper.getLatestRoulette(userId);
      print('HomePage: Dados da roleta obtidos: $rouletteData');

      final now = DateTime.now();
      print('HomePage: Calculando nextRouletteTime');
      nextRouletteTime = _calculateNextRouletteTime(now);
      print('HomePage: nextRouletteTime calculado: $nextRouletteTime');

      setState(() {
        usageTime = stats['totalTime'] ?? '0h00min';
        userRemainingTime = stats['remainingTime'] ?? '0h00min';
        messages = recados.map((r) => {
          'text': r['texto'],
          'time': r['dataHora'],
          'isOther': r['isOther'] == 1,
        }).toList();
        streakCount = streak;
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
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _calculateNextRouletteTime(DateTime now) {
    final next = now.add(const Duration(hours: 4));
    final hours = next.hour.toString().padLeft(2, '0');
    final minutes = next.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
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
                    ? FileImage(File(user!.photoUrl!))
                    : NetworkImage('https://via.placeholder.com/150'),
                child: user!.photoUrl == null
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
      onTap: () async { // MODIFICADO: Marcar como async (já está assim no seu código)
        print('HomePage: Navegando para /statistics');
        // MODIFICADO: Aguarda um resultado da StatisticScreen (já está assim no seu código)
        final result = await Navigator.pushNamed(context, '/statistics');

        // MODIFICADO: Se StatisticScreen retornar 'true' e o widget ainda estiver montado, recarregue os dados.
        // (já está assim no seu código)
        if (result == true && mounted) {
          print('HomePage: Retornou da StatisticScreen com sucesso, recarregando dados...');
          _loadData();
        } else {
          print('HomePage: Retornou da StatisticScreen, resultado: $result (sem recarregar ou widget desmontado)');
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
            onTap: () {
              print('HomePage: Navegando para /roulette');
              Navigator.pushNamed(context, '/roulette');
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
                              'Ontem',
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
            time,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}