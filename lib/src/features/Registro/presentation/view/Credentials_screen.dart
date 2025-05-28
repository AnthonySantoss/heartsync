import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:heartsync/servico/api_service.dart';

class CredentialsScreen extends StatefulWidget {
  final String name;
  final String birth;
  final VoidCallback onRegisterComplete;

  const CredentialsScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.onRegisterComplete,
  });

  @override
  CredentialsScreenState createState() => CredentialsScreenState();
}

class CredentialsScreenState extends State<CredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService(baseUrl: 'http://192.168.119.162:3000');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _apiService.sendVerificationCode(_emailController.text);
        print('Código de verificação enviado para ${_emailController.text}');

        Navigator.pushNamed(
          context,
          '/verification_code',
          arguments: {
            'email': _emailController.text,
            'name': widget.name,
            'birth': widget.birth,
            'password': _passwordController.text,
            'onRegisterComplete': widget.onRegisterComplete,
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar código: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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
                'Insira um e-mail e uma senha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
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
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Por favor, insira seu e-mail';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                          return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Por favor, insira sua senha';
                        if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Por favor, confirme sua senha';
                        if (value != _passwordController.text) return 'As senhas não coincidem';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 105),
              _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(double.infinity, 66),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Registrar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              const SizedBox(height: 140),
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
      ),
    );
  }
}