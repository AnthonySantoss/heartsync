import 'package:flutter/material.dart';

class Introducao extends StatefulWidget {
  const Introducao({super.key});

  @override
  State<Introducao> createState() => _IntroducaoState();
}

class _IntroducaoState extends State<Introducao> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;

  final List<String> imagens = [
    'lib/assets/images/perfilConjunto.png',
    'lib/assets/images/gerenciem_o_tempo.png',
    'lib/assets/images/atividadesemconjunto.png',
    'lib/assets/images/cultivembons.png',
  ];

  final List<String> textos = [
    'Um app em conjunto',
    'Gerenciem o tempo de vocês no celular',
    'Atividades em conjunto',
    'Cultivem bons hábitos em dupla',
  ];

  void _proximaPagina() {
    if (_paginaAtual < imagens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1338), Color(0xFF08050F)],
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
                Image.asset('lib/assets/images/logo.png', width: 94),
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
                    _paginaAtual = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        imagens[index],
                        fit: BoxFit.cover,
                        width: 400,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Text(
              textos[_paginaAtual],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _proximaPagina,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(356, 66),
                backgroundColor: const Color(0xFF7D48FE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Próximo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
