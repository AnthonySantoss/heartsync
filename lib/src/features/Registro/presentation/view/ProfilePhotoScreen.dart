import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/servico/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:get_it/get_it.dart';

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
  final ApiService _apiService = ApiService(baseUrl: 'http://192.168.0.8:3000');
  final DatabaseHelper _databaseHelper = GetIt.instance<DatabaseHelper>();

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

  Future<void> _continue() async {
    try {
      String? profileImagePath;
      bool temFoto = false;

      // Obter o localId do AuthManager
      final localId = await AuthManager.getLocalId();
      if (localId == null) {
        throw Exception('ID do usuário não encontrado. Por favor, faça login novamente.');
      }

      if (_selectedImageFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enviando imagem...')),
        );

        // Faz o upload da imagem usando ApiService
        final responseData = await _apiService.uploadImage(_selectedImageFile!);
        setState(() {
          imageUrl = responseData['imageUrl'];
          profileImagePath = imageUrl;
          temFoto = true;
        });

        // Atualizar o AuthManager com a URL da foto
        await AuthManager.updateUserProfile(photoUrl: profileImagePath);
      }

      // Atualizar o banco de dados com os dados da foto
      final db = await _databaseHelper.database;
      await db.update(
        'usuarios',
        {
          'temFoto': temFoto ? 1 : 0,
          'profileImagePath': profileImagePath,
        },
        where: 'id = ?',
        whereArgs: [localId],
      );

      // Chama o callback de registro concluído
      widget.onRegisterComplete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar imagem: $e')),
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