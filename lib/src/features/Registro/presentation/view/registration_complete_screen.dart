import 'package:flutter/material.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/domain/usecases/register_user_use_case.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _completeRegistration(BuildContext context) async {
    final registerUserUseCase = GetIt.instance<RegisterUserUseCase>();
    final prefs = await SharedPreferences.getInstance();

    try {
      // Salvar usuário no banco
      await registerUserUseCase.execute(
        nome: name,
        email: email,
        dataNascimento: birth,
        senha: password,
        temFoto: profileImagePath != null,
        heartcode: heartCode,
      );

      // Atualizar preferências
      await prefs.setBool('isFirstTime', false);
      await prefs.setBool('isLoggedIn', true);

      // Navegar para a homepage
      Navigator.pushReplacementNamed(context, '/homepage');
    } catch (e) {
      String errorMessage = 'Erro ao completar registro';
      if (e.toString().contains('Email já registrado')) {
        errorMessage = 'Este email já está em uso. Tente outro.';
      } else if (e.toString().contains('HeartCode já está em uso')) {
        errorMessage = 'Este HeartCode já está em uso. Tente outro.';
      } else {
        errorMessage = 'Erro inesperado: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Registro Concluído!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Você e seu parceiro estão sincronizados!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _completeRegistration(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Ir para a Homepage',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}