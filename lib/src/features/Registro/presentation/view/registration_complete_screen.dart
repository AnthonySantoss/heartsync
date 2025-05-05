import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Menu/presentation/view/Home_page_screen.dart';

class RegistrationCompleteScreen extends StatelessWidget {
  final String name;
  final String birth;
  final String email;
  final String password;
  final String? profileImagePath;
  final String heartCode;
  final String partnerHeartCode;

  const RegistrationCompleteScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
    this.profileImagePath,
    required this.heartCode,
    required this.partnerHeartCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/home.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                const Color(0xFF1E1338),
                const Color(0xFF08050F),
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 79.1),
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'lib/assets/images/logo.png',
                      width: 47.7,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'HeartSync',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Você completou o seu registro, ${name.split(' ').first}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Agora você pode explorar todas as funções do HeartSync',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7D48FE),
                    minimumSize: const Size(double.infinity, 66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Começar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Ajustado para melhor espaçamento
              ],
            ),
          ),
        ),
      ),
    );
  }
}