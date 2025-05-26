import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Birth_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback onRegisterComplete;

  const RegistrationScreen({super.key, required this.onRegisterComplete});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    if (_formKey.currentState!.validate()) {
      print('Navegando para BirthScreen com nome: ${_nameController.text}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BirthScreen(
            name: _nameController.text,
            onRegisterComplete: widget.onRegisterComplete,
          ),
        ),
      );
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
              const SizedBox(height: 40),
              const Text(
                'Seu nome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    filled: true,
                    fillColor: Colors.grey[900]!.withValues(alpha: 0.5),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(double.infinity, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 350),
              Text.rich(
                TextSpan(
                  text: 'Já possui uma conta?',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: ' Entrar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Navegando para /login');
                          Navigator.pushNamed(context, '/login');
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}