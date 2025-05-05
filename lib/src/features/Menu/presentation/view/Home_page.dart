import 'package:flutter/material.dart';

class Home_page extends StatelessWidget {
  const Home_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0020),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildUsageCard(),
              const SizedBox(height: 20),
              _buildMidCards(),
              const SizedBox(height: 20),
              _buildRecadosList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 74 + 20),
        Image.asset('lib/assets/images/logo.png', width: 94),
        const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildUsageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFAF3BEF), Color(0xFF27AD69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: const [
          Text(
            'Tempo de uso',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Isabela\n1h20min',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('Ricardo\n2h10min',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Seu tempo restante\n2h40min',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMidCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2C1A50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: const [
                Text('Roleta 🎡', style: TextStyle(color: Colors.white)),
                SizedBox(height: 8),
                Text('Próxima Roleta em:\n4h20min',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 4),
                Text('Ontem: Cinema 🍿',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF67200), Color(0xFFD00000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: const [
              Text('Série', style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              Icon(Icons.local_fire_department, color: Colors.white, size: 30),
              Text('3', style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecadosList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF2C1A50),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recados',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            _buildRecado('Comprar a ração do Sargento', '14:26'),
            _buildRecado('Trocar o pneu da sua bicicleta', 'Ontem',
                isOther: true),
            _buildRecado('Pneu furou!', 'Ontem', isOther: true),
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
            child: Icon(Icons.person, color: Colors.black),
            backgroundColor: isOther ? Colors.white : Colors.white,
            radius: 10,
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
