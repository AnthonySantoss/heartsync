import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Registro/presentation/view/registration_complete_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';

class HeartCodeInputScreen extends StatefulWidget {
  final String name;
  final String birth;
  final String email;
  final String password;
  final String? profileImagePath;
  final String heartCode;
  final VoidCallback onRegisterComplete;

  const HeartCodeInputScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
    this.profileImagePath,
    required this.heartCode,
    required this.onRegisterComplete,
  });

  @override
  HeartCodeInputScreenState createState() => HeartCodeInputScreenState();
}

class HeartCodeInputScreenState extends State<HeartCodeInputScreen> {
  final _heartCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitHeartCode() {
    if (_formKey.currentState!.validate()) {
      String partnerHeartCode = _heartCodeController.text;
      print('Heart Code do usuário: ${widget.heartCode}');
      print('Heart Code do parceiro: $partnerHeartCode');
      print('Dados do usuário: Nome: ${widget.name}, Nascimento: ${widget.birth}, E-mail: ${widget.email}, Senha: ${widget.password}, Imagem: ${widget.profileImagePath}');

      // Simula a validação do Heart Code do parceiro
      if (partnerHeartCode.isNotEmpty && partnerHeartCode != widget.heartCode) {
        widget.onRegisterComplete(); // Completa o registro
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrationCompleteScreen(
              name: widget.name,
              birth: widget.birth,
              email: widget.email,
              password: widget.password,
              profileImagePath: widget.profileImagePath,
              heartCode: widget.heartCode,
              partnerHeartCode: partnerHeartCode,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Heart Code inválido ou igual ao seu!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _heartCodeController.dispose();
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
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Abrir scanner de QR Code (simulação)!')),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
                    ),
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
                'Insira o Heart Code do seu parceiro para enviar a solicitação de sincronia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _heartCodeController,
                  decoration: InputDecoration(
                    hintText: '#123...',
                    hintStyle: const TextStyle(color: Colors.grey),
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
                    if (value == null || value.isEmpty)
                      return 'Por favor, insira o Heart Code do seu parceiro';
                    if (!value.startsWith('#') || value.length < 5)
                      return 'O Heart Code deve começar com # e ter pelo menos 4 caracteres';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submitHeartCode,
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
      ),
    );
  }
}