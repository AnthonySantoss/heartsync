import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:heartsync/src/features/registro/presentation/view/heart_code_screen.dart'; // Importe a nova tela

class ProfilePhotoScreen extends StatefulWidget {
  final String name;
  final String birth;
  final String email;
  final String password;

  const ProfilePhotoScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
  });

  @override
  ProfilePhotoScreenState createState() => ProfilePhotoScreenState();
}

class ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  String? _selectedImagePath;

  void _pickImage() {
    setState(() {
      _selectedImagePath = 'lib/assets/images/placeholder_photo.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagem selecionada (simulação)!')),
    );
  }

  void _continue() {
    print('Imagem selecionada: $_selectedImagePath');
    print('Dados do usuário: Nome: ${widget.name}, Nascimento: ${widget.birth}, E-mail: ${widget.email}, Senha: ${widget.password}');
    // Navegar para a tela de Heart Code
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeartCodeScreen(
          name: widget.name,
          birth: widget.birth,
          email: widget.email,
          password: widget.password,
          profileImagePath: _selectedImagePath,
        ),
      ),
    );
  }

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
              'Adicione uma foto de perfil',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 90,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImagePath != null
                      ? AssetImage(_selectedImagePath!)
                      : null,
                  child: _selectedImagePath == null
                      ? const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  )
                      : null,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF7D48FE),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _continue,
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
            const SizedBox(height: 20),
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
                        Navigator.pushNamed(context, '/login');
                      },
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