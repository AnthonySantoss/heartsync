import 'package:flutter/material.dart';

// Rotas do aplicativo
import 'package:heartsync/Intro_screen.dart';
import 'package:heartsync/src/features/home/presentation/view/Home_screen.dart';
import 'package:heartsync/src/features/login/presentation/view/Login_screen.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/Menu/presentation/view/Home_page_screen.dart';
import 'package:heartsync/src/features/Menu/presentation/view/statistic_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Birth_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Credentials_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/ProfilePhotoScreen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Registration_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/verification_code_screen.dart';
import 'package:heartsync/src/features/Roleta/presentation/view/Roulette_screen.dart';

// Dependências e serviços
import 'package:get_it/get_it.dart';
import 'package:heartsync/servico/api_service.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRoutes {
  static const String initialRouteSelector = '/';
  static const String intro = '/intro';
  static const String home = '/home';
  static const String register = '/register';
  static const String birth = '/birth';
  static const String credentials = '/credentials';
  static const String verificationCode = '/verification_code';
  static const String profilePhoto = '/profile-photo';
  static const String login = '/login';
  static const String homePage = '/homepage';
  static const String profile = '/profile';
  static const String statistics = '/statistics';
  static const String roulette = '/roulette';

  static Map<String, WidgetBuilder> getRoutes(SharedPreferences prefs) {
    return {
      initialRouteSelector: (context) {
        bool? isFirstTime = prefs.getBool('isFirstTime');
        bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        print('AppRoutes: Verificando estado inicial - isFirstTime: $isFirstTime, isLoggedIn: $isLoggedIn');
        if (isLoggedIn) {
          print('AppRoutes: Usuário logado, redirecionando para /homepage');
          return const HomePage();
        } else {
          if (isFirstTime == null || isFirstTime == true) {
            print('AppRoutes: Primeira vez, redirecionando para /intro');
            return const Introducao();
          } else {
            print('AppRoutes: Não é primeira vez, redirecionando para /home');
            return HomeScreen(
              onLoginComplete: () => _handleLogin(context, prefs),
              onRegisterComplete: () => Navigator.pushNamed(context, AppRoutes.register),
            );
          }
        }
      },
      intro: (context) => const Introducao(),
      home: (context) => HomeScreen(
        onLoginComplete: () => _handleLogin(context, prefs),
        onRegisterComplete: () => Navigator.pushNamed(context, AppRoutes.register),
      ),
      login: (context) => LoginScreen(
        onLoginComplete: () => _handleLogin(context, prefs),
      ),
      register: (context) => RegistrationScreen(
        onRegisterComplete: () => Navigator.pushNamed(context, AppRoutes.birth),
      ),
      birth: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        print('AppRoutes: Navegando para /birth com argumentos: $args');
        if (args != null) {
          return BirthScreen(
            name: args['name'] as String? ?? '',
            onRegisterComplete: () {
              Navigator.pushNamed(context, AppRoutes.credentials, arguments: {
                'name': args['name'],
                'onRegisterComplete': () {
                  Navigator.pushNamed(context, AppRoutes.verificationCode);
                },
              });
            },
          );
        }
        return _ErrorRouteWidget(routeName: birth, args: args);
      },
      credentials: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        print('AppRoutes: Navegando para /credentials com argumentos: $args');
        if (args != null) {
          return CredentialsScreen(
            name: args['name'] as String? ?? '',
            birth: args['birth'] as String? ?? '',
            onRegisterComplete: args['onRegisterComplete'] as VoidCallback? ??
                    () => Navigator.pushNamed(context, AppRoutes.verificationCode),
          );
        }
        return _ErrorRouteWidget(routeName: credentials, args: args);
      },
      verificationCode: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        print('AppRoutes: Navegando para /verification_code com argumentos: $args');
        if (args != null) {
          return VerificationCodeScreen(
            email: args['email'] as String? ?? '',
            name: args['name'] as String? ?? '',
            birth: args['birth'] as String? ?? '',
            password: args['password'] as String? ?? '',
            onRegisterComplete: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homePage, (route) => false);
            },
          );
        }
        return _ErrorRouteWidget(routeName: verificationCode, args: args);
      },
      profilePhoto: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        print('AppRoutes: Navegando para /profile-photo com argumentos: $args');
        if (args != null) {
          return ProfilePhotoScreen(
            name: args['name'] as String? ?? '',
            birth: args['birth'] as String? ?? '',
            email: args['email'] as String? ?? '',
            password: args['password'] as String? ?? '',
            onRegisterComplete: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homePage, (route) => false);
            },
          );
        }
        return _ErrorRouteWidget(routeName: profilePhoto, args: args);
      },
      homePage: (context) => const HomePage(),
      profile: (context) => const ProfileScreen(),
      statistics: (context) => const StatisticScreen(),
      roulette: (context) => _buildRouletteScreen(),
    };
  }

  // Função auxiliar para construir a tela de roleta com dados assíncronos
  static Widget _buildRouletteScreen() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchRouletteData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          print('AppRoutes: Erro ao carregar dados para /roulette: ${snapshot.error}');
          return _ErrorRouteWidget(
            routeName: roulette,
            args: {'error': snapshot.error?.toString() ?? 'Dados não disponíveis'},
          );
        }

        final data = snapshot.data!;
        return RouletteScreen(
          userId: data['userId'] as int,
          imageUrl: data['imageUrl'] as String?,
        );
      },
    );
  }

  // Função para buscar userId e imageUrl de forma assíncrona
  static Future<Map<String, dynamic>> _fetchRouletteData() async {
    try {
      final userIdStr = await AuthManager.getServerId();
      final userId = int.tryParse(userIdStr ?? '') ?? 0;
      if (userId == 0) {
        print('AppRoutes: userId inválido para /roulette');
        throw Exception('userId inválido: $userIdStr');
      }

      final apiService = GetIt.instance<ApiService>();
      final profile = await apiService.getMyProfile();
      print('AppRoutes: Perfil carregado - photoUrl: ${profile.photoUrl}');
      return {
        'userId': userId,
        'imageUrl': profile.photoUrl ?? '',
      };
    } catch (e) {
      print('AppRoutes: Erro ao buscar dados para /roulette: $e');
      throw e; // Repropaga a exceção para o FutureBuilder
    }
  }

  static Widget _ErrorRouteWidget({String? routeName, dynamic args}) {
    print("AppRoutes: Rota não encontrada ou argumentos inválidos: $routeName com argumentos: $args");
    return Scaffold(
      appBar: AppBar(title: const Text('Erro de Rota')),
      body: Center(child: Text('Rota não encontrada ou args inválidos para: $routeName\nErro: ${args['error'] ?? 'Desconhecido'}')),
    );
  }

  static Future<void> _handleLogin(BuildContext context, SharedPreferences prefs) async {
    print('AppRoutes: _handleLogin - Navegando para /homepage');
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homePage, (route) => false);
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    print('AppRoutes: Rota desconhecida acessada: ${settings.name}');
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Rota Desconhecida')),
        body: Center(child: Text('Rota não encontrada: ${settings.name}')),
      ),
    );
  }
}