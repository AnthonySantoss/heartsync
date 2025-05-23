import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Registro/presentation/view/ProfilePhotoScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/utils/auth_manager.dart';

// Telas de Fluxo Principal
import 'package:heartsync/Intro_screen.dart';
import 'package:heartsync/src/features/home/presentation/view/Home_screen.dart';
import 'package:heartsync/src/features/login/presentation/view/Login_screen.dart';
import 'package:heartsync/src/features/Menu/presentation/view/Home_page_screen.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/Menu/presentation/view/statistic_screen.dart';
import 'package:heartsync/src/features/Roleta/presentation/view/Roulette_screen.dart';

// Telas de Fluxo de Registro
import 'package:heartsync/src/features/Registro/presentation/view/Registration_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Birth_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Credentials_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/verification_code_screen.dart';

class AppRoutes {
  static const String initialRouteSelector = '/';
  static const String intro = '/intro';
  static const String home = '/home';
  static const String register = '/register';
  static const String birth = '/birth';
  static const String credentials = '/credentials';
  static const String verificationCode = '/verification_code';
  static const String profilePhoto = '/profile-photo'; // Adicionado
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

        if (isLoggedIn) {
          return const HomePage();
        } else {
          if (isFirstTime == null || isFirstTime == true) {
            return const Introducao();
          } else {
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
        if (args != null) {
          return VerificationCodeScreen(
            email: args['email'] as String? ?? '',
            name: args['name'] as String? ?? '',
            birth: args['birth'] as String? ?? '',
            password: args['password'] as String? ?? '',
            verificationCode: args['verificationCode'] as String? ?? '',
            onRegisterComplete: () {
              // Navegação para a ProfilePhotoScreen agora é tratada dentro da VerificationCodeScreen
            },
          );
        }
        return _ErrorRouteWidget(routeName: verificationCode, args: args);
      },
      profilePhoto: (context) { // Adicionado
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
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
      roulette: (context) => const RouletteScreen(),
    };
  }

  static Widget _ErrorRouteWidget({String? routeName, dynamic args}) {
    print("ROTA NÃO ENCONTRADA OU ARGUMENTOS INVÁLIDOS: $routeName com argumentos: $args");
    return Scaffold(
      appBar: AppBar(title: const Text('Erro de Rota')),
      body: Center(child: Text('Rota não encontrada ou args inválidos para: $routeName')),
    );
  }

  static Future<void> _handleLogin(BuildContext context, SharedPreferences prefs) async {
    print('AppRoutes: _handleLogin - Navegando para /homepage');
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homePage, (route) => false);
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Rota Desconhecida')),
        body: Center(child: Text('Rota não encontrada: ${settings.name}')),
      ),
    );
  }
}