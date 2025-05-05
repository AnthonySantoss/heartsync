import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Registration_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Chave para o formulário (validação)
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Estado de carregamento
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BackgroundWidget(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Cabeçalho (logo e botão voltar)
                Padding(
                  padding: const EdgeInsets.only(top: 79.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          'lib/assets/images/Back.png',
                          width: 27,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'lib/assets/images/logo.png',
                            width: 47.7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 47),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Título
                const Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entre com a sua conta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                // Campo de email
                _buildEmailField(),
                const SizedBox(height: 10),
                // Campo de senha
                _buildPasswordField(),
                const SizedBox(height: 9),
                // Esqueceu a senha
                _buildForgotPassword(),
                const SizedBox(height: 30),
                // Botão de login
                _buildLoginButton(context),
                const SizedBox(height: 30),
                // Link para registro
                _buildRegisterText(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'E-mail ou HeartCode',
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFF4D3192),
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira seu e-mail ou HeartCode';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Senha',
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFF4D3192),
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira sua senha';
        }
        if (value.length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implementar recuperação de senha
        },
        child: const Text(
          'Esqueceu a sua senha?',
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isLoading = true);
            try {
              // TODO: Implementar chamada ao back-end
              // await AuthService.login(
              //   _emailController.text,
              //   _passwordController.text,
              // );
              // Navigator.pushReplacement(...);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro: $e')),
              );
            } finally {
              setState(() => _isLoading = false);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7D48FE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Entrar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterText(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Registration_screen()),
        );
      },
      child: const Text.rich(
        TextSpan(
          text: 'Não possui uma conta? ',
          children: [
            TextSpan(
              text: 'Registrar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Método para atualizar o estado (simulado para StatelessWidget)
  void setState(VoidCallback fn) {
    fn();
  }
}