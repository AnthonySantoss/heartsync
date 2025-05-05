import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Menu/presentation/view/statistic_screen.dart';
import 'package:heartsync/src/features/Roleta/presentation/view/Roulette_screen.dart';

class HomePage extends StatelessWidget {
  // Dados que o back-end deve fornecer
  final String? profileImageUrl; // URL da imagem de perfil do usuário
  final String isabelaUsageTime; // Ex.: "1h20min"
  final String ricardoUsageTime; // Ex.: "2h10min"
  final String userRemainingTime; // Ex.: "2h40min"
  final String nextRouletteTime; // Ex.: "4h20min"
  final String lastRouletteActivity; // Ex.: "Cinema 🍿"
  final String streakCount; // Ex.: "3"
  final List<Map<String, dynamic>> messages; // Lista de recados

  const HomePage({
    super.key,
    this.profileImageUrl,
    this.isabelaUsageTime = '1h20min',
    this.ricardoUsageTime = '2h10min',
    this.userRemainingTime = '2h40min',
    this.nextRouletteTime = '4h20min',
    this.lastRouletteActivity = 'Cinema 🍿',
    this.streakCount = '3',
    this.messages = const [
      {'text': 'Comprar a ração do Sargento', 'time': '14:26', 'isOther': false},
      {'text': 'Trocar o pneu da sua bicicleta', 'time': 'Ontem', 'isOther': true},
      {'text': 'Pneu furou!', 'time': 'Ontem', 'isOther': true},
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF170D2E), // 100%
              Color(0xFF010101), // 0%
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
                _buildHeader(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(),
        ),
        Image.asset('lib/assets/images/logo.png', width: 52),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: profileImageUrl == null
                  ? const Icon(Icons.person, color: Colors.black)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const StatisticScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB02D78), // 100%
              Color(0xFF230640), // 50%
              Color(0xFF015021), // 0%
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
              style: TextStyle(color: Color(0xFFD9D9D9), fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Isabela',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFD9D9D9), fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isabelaUsageTime,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Ricardo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFD9D9D9), fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ricardoUsageTime,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RouletteScreen(),
                ),
              );
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
              const Text('Série', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                    streakCount,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
            backgroundColor: isOther ? Colors.white : Colors.white,
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