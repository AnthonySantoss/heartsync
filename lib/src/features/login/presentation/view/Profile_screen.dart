import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:heartsync/servico/api_service.dart';
import 'package:heartsync/data/datasources/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final apiService = ApiService();
    final dbService = DatabaseHelper();
    try {
      final profileData = await apiService.getUserProfile();
      print('API Response: $profileData'); // Debug print
      await dbService.saveUserProfile(profileData);
      setState(() {
        user = profileData;
        isLoading = false;
      });
    } catch (e) {
      final cachedData = await dbService.getCachedUserProfile();
      if (cachedData != null) {
        setState(() {
          user = cachedData;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar perfil. Tente novamente.';
          isLoading = false;
        });
        print('Erro ao buscar dados do usuário: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        padding: const EdgeInsets.all(0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
            : SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(0),
                decoration: const BoxDecoration(
                  color: Color(0xFF210E45),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Image.asset(
                            'lib/assets/images/Back.png',
                            width: 27,
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Perfil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Ação para menu adicional
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFDBDBDB),
                      backgroundImage: user?['profileImagePath'] != null
                          ? NetworkImage(user!['profileImagePath'] as String)
                          : null,
                      child: user?['profileImagePath'] == null
                          ? const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white,
                      )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user?['nome'] as String? ?? 'Usuário',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?['heartcode'] as String? ?? 'Sem heartcode',
                      style: const TextStyle(
                        color: Color(0xFF5F38BE),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF210E45),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                user?['dataNascimento'] as String? ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Aniversário',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '|',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 20,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                user?['email'] as String? ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'E-mail',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF210E45),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          print('Abrir link para avaliação do aplicativo');
                        },
                        child: const Text(
                          'Avaliar o Aplicativo',
                          style: TextStyle(
                            color: Color(0xFF5F38BE),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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