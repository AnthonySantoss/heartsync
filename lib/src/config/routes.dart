import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/features/home/presentation/view/Home_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Registration_screen.dart';
import 'package:heartsync/src/features/login/presentation/view/Login_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Birth_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Credentials_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/verification_code_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/ProfilePhotoScreen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/heart_code_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/heart_code_exchange_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/heart_code_qr_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/heart_code_input_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/registration_complete_screen.dart';
import 'package:heartsync/src/features/Menu/presentation/view/Home_page_screen.dart';
import 'package:heartsync/Intro_screen.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';
import 'package:heartsync/src/features/Menu/presentation/view/statistic_screen.dart';
import 'package:heartsync/src/features/Roleta/presentation/view/Roulette_screen.dart';
import 'package:heartsync/src/features/Registro/presentation/view/heart_code_exchange_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes(SharedPreferences prefs) {
    return {
      '/home': (context) => HomeScreen(
        onLoginComplete: () => _handleLogin(context, prefs),
        onRegisterComplete: () => _handleRegistration(context, prefs),
      ),
      '/register': (context) => RegistrationScreen(
        onRegisterComplete: () => _handleRegistration(context, prefs),
      ),
      '/login': (context) => LoginScreen(
        onLoginComplete: () => _handleLogin(context, prefs),
      ),
      '/intro': (context) => Introducao(),
      '/birth': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return BirthScreen(
          name: args['name'] as String,
          onRegisterComplete: args['onRegisterComplete'] as VoidCallback,
        );
      },
      '/credentials': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return CredentialsScreen(
          name: args['name'] as String,
          birth: args['birth'] as String,
          onRegisterComplete: args['onRegisterComplete'] as VoidCallback,
        );
      },
      '/verification': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return VerificationCodeScreen(
          email: args['email'] as String,
          name: args['name'] as String,
          birth: args['birth'] as String,
          password: args['password'] as String,
          verificationCode: args['verificationCode'] as String,
          onRegisterComplete: args['onRegisterComplete'] as VoidCallback,
        );
      },
      '/profile-photo': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ProfilePhotoScreen(
          name: args['name'] as String,
          birth: args['birth'] as String,
          email: args['email'] as String,
          password: args['password'] as String,
          onRegisterComplete: args['onRegisterComplete'] as VoidCallback,
        );
      },
      '/heart-code': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return HeartCodeScreen(
          name: args['name'] as String,
          birth: args['birth'] as String,
          email: args['email'] as String,
          password: args['password'] as String,
          profileImagePath: args['profileImagePath'] as String?,
          onRegisterComplete: args['onRegisterComplete'] as VoidCallback,
        );
      },
      '/heart-code-exchange': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return HeartCodeExchangeScreen(
          name: args['name'] as String,
          birth: args['birth'] as String,
          email: args['email'] as String,
          password: args['password'] as String,
          profileImagePath: args['profileImagePath'] as String?,
          onRegisterComplete: args['onRegisterComplete'] as VoidCallback,
        );
      },
      '/heart-code-qr': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return HeartCodeQRScreen(
          name: args['name'] as String,
          birth: args['birth'] as String,
          email: args['email'] as String,
          password: args['password'] as String,
          profileImagePath: args['profileImagePath'] as String?,
          onRegisterComplete: args['onRegisterComplete'] as VoidCallback,
        );
      },
      '/heart-code-input': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return HeartCodeInputScreen(
          name: args['name'] as String,
          birth: args['birth'] as String,
          email: args['email'] as String,
          password: args['password'] as String,
          profileImagePath: args['profileImagePath'] as String?,
          heartCode: args['heartCode'] as String,
          onRegisterComplete: args['onRegisterComplete'] as VoidCallback,
        );
      },
      '/homepage': (context) => HomePage(),
      '/profile': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
        return ProfileScreen(
          userName1: args['userName1'] as String? ?? 'Isabela',
          heartCode1: args['heartCode1'] as String? ?? '#543823332PA',
          birthDate1: args['birthDate1'] as String? ?? '12.03.2004',
          userName2: args['userName2'] as String? ?? 'Ricardo',
          heartCode2: args['heartCode2'] as String? ?? '#123456789AB',
          birthDate2: args['birthDate2'] as String? ?? '07.08.2003',
          anniversaryDate: args['anniversaryDate'] as String? ?? '15.05.2019',
          syncDate: args['syncDate'] as String? ?? '01.02.2025',
          imageUrl1: args['imageUrl1'] as String?,
          imageUrl2: args['imageUrl2'] as String?,
        );
      },
      '/statistic': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
        return StatisticScreen(
          codigoConexao: args['codigoConexao'] as String? ?? 'default_codigo', // Substitua por um código padrão ou trate erros
        );
      },
      '/roulette': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
        return RouletteScreen(
          initialActivities: (args['initialActivities'] as List<dynamic>?)?.map((e) => Activity(
            name: e['name'] as String,
            blockTime: e['blockTime'] as String,
          )).toList() ?? const [
            Activity(name: 'Filme', blockTime: '1 hora'),
            Activity(name: 'Jogar...', blockTime: '1h30min'),
            Activity(name: 'Fazer...', blockTime: '2 horas'),
            Activity(name: 'Assistir...', blockTime: '1 hora'),
            Activity(name: 'Domir...', blockTime: '30 minutos'),
          ],
          imageUrl: args['imageUrl'] as String?,
          dayUsed: args['dayUsed'] as String? ?? '3',
        );
      },
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('Rota não encontrada: ${settings.name}'),
        ),
      ),
    );
  }

  static Future<void> _handleRegistration(BuildContext context, SharedPreferences prefs) async {
    await prefs.setBool('isFirstTime', false);
    await prefs.setBool('isLoggedIn', true);
    print('Registration completed - Navigating to /homepage'); // Debug
    Navigator.pushReplacementNamed(context, '/homepage');
  }

  static Future<void> _handleLogin(BuildContext context, SharedPreferences prefs) async {
    await prefs.setBool('isLoggedIn', true);
    print('Login completed - Navigating to /homepage'); // Debug
    Navigator.pushReplacementNamed(context, '/homepage');
  }
}