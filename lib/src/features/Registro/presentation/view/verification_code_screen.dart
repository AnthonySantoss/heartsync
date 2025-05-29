import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/domain/usecases/register_user_use_case.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:heartsync/servico/api_service.dart';
import 'package:get_it/get_it.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final String name;
  final String birth;
  final String password;
  final VoidCallback onRegisterComplete;

  const VerificationCodeScreen({
    super.key,
    required this.email,
    required this.name,
    required this.birth,
    required this.password,
    required this.onRegisterComplete,
  });

  @override
  VerificationCodeScreenState createState() => VerificationCodeScreenState();
}

class VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasVerified = false; // Nova variável para rastrear se a verificação já foi feita
  final ApiService _apiService = ApiService(baseUrl: 'http://192.168.0.29:3000');

  Future<void> _verifyCode() async {
    if (_hasVerified) {
      print('Verificação: Código já foi verificado, ignorando nova tentativa.');
      return; // Impede novas tentativas após a verificação bem-sucedida
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        print('Verificação: Iniciando verificação do código para e-mail: ${widget.email}, código inserido: ${_codeController.text}');
        // Verificar o código via API
        await _apiService.verifyCode(widget.email, _codeController.text);
        print('Verificação: Código verificado com sucesso para ${widget.email}');

        setState(() {
          _hasVerified = true; // Marca como verificado
        });

        // Registrar o usuário após verificação bem-sucedida
        final registerUserUseCase = GetIt.instance<RegisterUserUseCase>();
        final prefs = await SharedPreferences.getInstance();

        print('Registro: Iniciando registro com nome: ${widget.name}, e-mail: ${widget.email}, data de nascimento: ${widget.birth}, senha: [oculta]');
        final response = await _apiService.register({
          'nome': widget.name,
          'email': widget.email,
          'dataNascimento': widget.birth,
          'senha': widget.password,
        });

        final serverId = response['serverId'].toString(); // Forçar conversão para string
        final token = response['token'] as String?;
        final localId = await registerUserUseCase.execute(
          nome: widget.name,
          email: widget.email,
          dataNascimento: widget.birth,
          senha: widget.password,
          temFoto: false,
          profileImagePath: null,
        );

        print('Registro: Usuário registrado com ID local: $localId, ServerID: $serverId, Token: [oculto]');

        // Salvar dados da sessão
        await AuthManager.saveSessionData(
          token: token ?? '',
          serverId: serverId,
          localId: localId,
          name: widget.name,
          email: widget.email,
          photoUrl: null,
        );

        // Definir flags no SharedPreferences
        await prefs.setBool('isFirstTime', false);
        await prefs.setBool('isLoggedIn', true);

        // Chamar o callback de registro completo
        widget.onRegisterComplete();

        // Navegar para a ProfilePhotoScreen
        await Navigator.pushNamed(
          context,
          '/profile-photo',
          arguments: {
            'name': widget.name,
            'birth': widget.birth,
            'email': widget.email,
            'password': widget.password,
          },
        );
      } catch (e) {
        print('Erro durante a verificação/registro: $e');
        String errorMessage = 'Erro ao completar registro';
        if (e.toString().contains('Email já registrado')) {
          errorMessage = 'Este email já está em uso. Tente outro.';
        } else if (e.toString().contains('Código inválido')) {
          errorMessage = 'Código inválido. Tente novamente.';
        } else if (e.toString().contains('Código expirado')) {
          errorMessage = 'Código expirado. Solicite um novo código.';
        } else {
          errorMessage = 'Erro inesperado: $e';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BackgroundWidget(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
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
                'Insira o código de verificação',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enviamos um código para ${widget.email}',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Código de verificação',
                    labelStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    filled: true,
                    fillColor: Colors.grey[900]!.withValues(alpha: 0.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF4D3192), width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, insira o código';
                    if (value.length != 6) return 'O código deve ter 6 dígitos';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 105),
              ElevatedButton(
                onPressed: (_isLoading || _hasVerified) ? null : _verifyCode, // Desabilita o botão após verificação
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(double.infinity, 66),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  'Verificar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }
}