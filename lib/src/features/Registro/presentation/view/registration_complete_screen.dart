import 'package:flutter/material.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/domain/usecases/register_user_use_case.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationCompleteScreen extends StatefulWidget {
  final String name;
  final String birth;
  final String email;
  final String password;
  final String? profileImagePath;

  const RegistrationCompleteScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
    this.profileImagePath,
  });

  @override
  State<RegistrationCompleteScreen> createState() => _RegistrationCompleteScreenState();
}

class _RegistrationCompleteScreenState extends State<RegistrationCompleteScreen> {
  bool _isLoading = false;

  Future<void> _completeRegistration() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final registerUserUseCase = GetIt.instance<RegisterUserUseCase>();
    final prefs = await SharedPreferences.getInstance();

    try {
      final localId = await registerUserUseCase.execute(
        nome: widget.name,
        email: widget.email,
        dataNascimento: widget.birth,
        senha: widget.password,
        temFoto: widget.profileImagePath != null,
        profileImagePath: widget.profileImagePath,
      );

      await AuthManager.saveSessionData(
        token: 'local-auth-token',
        serverId: 'local-$localId',
        localId: localId,
        name: widget.name,
        email: widget.email,
        photoUrl: widget.profileImagePath,
      );

      await prefs.setBool('isFirstTime', false);
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacementNamed(context, '/homepage');
    } catch (e) {
      String errorMessage = 'Erro ao completar registro';
      if (e.toString().contains('UNIQUE constraint failed') || e.toString().contains('Email já registrado')) {
        errorMessage = 'Este email já está em uso. Tente outro.';
      } else {
        errorMessage = 'Erro inesperado: $e';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                'Bem-vindo(a) ao HeartSync!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _completeRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
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