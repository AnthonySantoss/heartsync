import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';

class Registration_screen extends StatelessWidget {
  const Registration_screen({super.key});

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
                      icon: Image.asset(
                        'lib/assets/images/Back.png',
                        width: 27,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
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

              // Espaçamento entre o cabeçalho e os campos
              const SizedBox(height: 40),

              // Campos do formulário
              _buildNome(),
              const SizedBox(height: 20),
              _buildBirth(),
              const SizedBox(height: 20),
              _buildEmail(),
              const SizedBox(height: 20),
              _buildPassword(),
              const SizedBox(height: 20),
              _buildConfirmPassword(),
              const SizedBox(height: 20),
              _buildLoginButton(context),
              const SizedBox(height: 20),
              _buildRegisterText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNome() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Nome',
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: Colors.grey[900]!.withOpacity(0.5),
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
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildBirth() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'dd / mm / aaaa',
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: Colors.grey[900]!.withOpacity(0.5),
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
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildEmail() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'E-mail',
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: Colors.grey[900]!.withOpacity(0.5),
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
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildPassword() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Senha',
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: Colors.grey[900]!.withOpacity(0.5),
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
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildConfirmPassword() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Senha',
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        filled: true,
        fillColor: Colors.grey[900]!.withOpacity(0.5),
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
      ),
      style: const TextStyle(color: Colors.white),
    );
  }



  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Lógica de login
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7D48FE),
        minimumSize: const Size(double.infinity, 66),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Registrar',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRegisterText() {
    return const Text.rich(
      TextSpan(
        text: 'Já possui uma conta?',
        children: [
          TextSpan(
            text: ' Entrar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

}