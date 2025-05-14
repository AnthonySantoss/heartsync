import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Registro/presentation/view/heart_code_exchange_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';

class HeartCodeScreen extends StatelessWidget {
  final String name;
  final String birth;
  final String email;
  final String password;
  final String? profileImagePath;
  final VoidCallback onRegisterComplete;

  const HeartCodeScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
    this.profileImagePath,
    required this.onRegisterComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BackgroundWidget(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 79.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Image.asset('lib/assets/images/Back.png', width: 27),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset('lib/assets/images/logo.png', width: 47.7),
                    ),
                  ),
                  const SizedBox(width: 47),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Heart Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Para sincronizar com o dispositivo do seu parceiro, vocês precisam trocar os seus Heart Codes',
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
                Navigator.pushNamed(
                  context,
                  '/heart-code-exchange',
                  arguments: {
                    'name': name,
                    'birth': birth,
                    'email': email,
                    'password': password,
                    'profileImagePath': profileImagePath,
                    'onRegisterComplete': onRegisterComplete,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D48FE),
                minimumSize: const Size(double.infinity, 66),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                text: 'Já possui uma conta?',
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400),
                children: [
                  TextSpan(
                    text: ' Entrar',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.pushNamed(context, '/login'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}