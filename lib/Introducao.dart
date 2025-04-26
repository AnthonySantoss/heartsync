import 'package:flutter/material.dart';

class Introducao extends StatefulWidget {
  const Introducao({super.key});

  @override
  State<Introducao> createState() => _IntroducaoState();
}

class _IntroducaoState extends State<Introducao> {
  final PageController _pageController = PageController();

  final List<String> imagens = [
    'lib/assets/images/perfilConjunto.png',
    'lib/assets/images/gerenciem_o_tempo.png',
    'lib/assets/images/atividadesemconjunto.png',
    'lib/assets/images/cultivembons.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E1338),
              Color(0xFF08050F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 74 + 20),
                Image.asset(
                  'lib/assets/images/logo.png',
                  width: 94,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Pular',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagens.length,
                onPageChanged: (index) {
                  setState(() {
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          imagens[index],
                          fit: BoxFit.cover,
                          width: 400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const DefaultTextStyle(
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Um app em'),
                  SizedBox(height: 8),
                  Text('Conjunto'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(356, 66),
                backgroundColor: const Color(0xFF7D48FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Próximo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}