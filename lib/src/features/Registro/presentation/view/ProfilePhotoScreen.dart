import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Registro/presentation/view/heart_code_screen.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfilePhotoScreen extends StatefulWidget {
  final String name;
  final String birth;
  final String email;
  final String password;
  final VoidCallback onRegisterComplete;

  const ProfilePhotoScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
    required this.onRegisterComplete,
  });

  @override
  ProfilePhotoScreenState createState() => ProfilePhotoScreenState();
}

class ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  File? _selectedImageFile;
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem selecionada com sucesso!')),
      );
    }
  }

  void _continue() async {
    if (_selectedImageFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enviando imagem...')),
      );

      final uploadedUrl = await uploadImage(_selectedImageFile!);
      if (uploadedUrl != null) {
        setState(() {
          imageUrl = uploadedUrl;
        });

        Navigator.pushNamed(
          context,
          '/heart-code-exchange',
          arguments: {
            'name': widget.name,
            'birth': widget.birth,
            'email': widget.email,
            'password': widget.password,
            'profileImagePath': imageUrl,
            'onRegisterComplete': widget.onRegisterComplete,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar imagem.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma foto de perfil.')),
      );
    }
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
                  backgroundImage: _selectedImageFile != null
                      ? FileImage(_selectedImageFile!)
                      : null,
                  child: _selectedImageFile == null
                      ? const Icon(Icons.person, size: 80, color: Colors.white)
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
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
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
                style: const TextStyle(fontSize: 18, color: Colors.white),
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
    );
  }
}

Future<String?> uploadImage(File imageFile) async {
  try {
    var uri = Uri.parse('http://192.168.1.14:3000/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      print('Resposta do servidor: $responseData');

      // Tenta converter de JSON
      final decoded = jsonDecode(responseData);
      return decoded['imageUrl']; // ou o campo correto que o back-end retorna
    } else {
      print('Erro no envio. Código: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Exceção ao enviar imagem: $e');
    return null;
  }
}
