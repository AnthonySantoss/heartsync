import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Registro/presentation/view/ProfilePhotoScreen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final String name;
  final String birth;
  final String password;
  final String verificationCode;
  final VoidCallback onRegisterComplete;

  const VerificationCodeScreen({
    super.key,
    required this.email,
    required this.name,
    required this.birth,
    required this.password,
    required this.verificationCode,
    required this.onRegisterComplete,
  });

  @override
  VerificationCodeScreenState createState() => VerificationCodeScreenState();
}

class VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _verifyCode() {
    if (_formKey.currentState!.validate()) {
      if (_codeController.text == widget.verificationCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código verificado com sucesso!')),
        );
        Navigator.pushNamed(
          context,
          '/profile-photo',
          arguments: {
            'name': widget.name,
            'birth': widget.birth,
            'email': widget.email,
            'password': widget.password,
            'onRegisterComplete': widget.onRegisterComplete,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código inválido! Tente novamente.')),
        );
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
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(double.infinity, 66),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
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