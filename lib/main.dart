import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/config/routes.dart';
import 'di/injection.dart' as di; // Importação para injeção de dependências

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inicializa o ambiente Flutter para operações assíncronas
  final prefs = await SharedPreferences.getInstance(); // Obtém a instância do SharedPreferences
  await di.init(); // Inicializa as injeções de dependência
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartSync', // Título do aplicativo
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema padrão
      ),
      initialRoute: _getInitialRoute(),
      routes: AppRoutes.getRoutes(prefs), // Define as rotas dinamicamente com base no SharedPreferences
      onUnknownRoute: AppRoutes.onUnknownRoute, // Lida com rotas desconhecidas
    );
  }

  String _getInitialRoute() {
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true; // Valor padrão true se não existir
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // Valor padrão false se não existir
    print('Initial Route - isFirstTime: $isFirstTime, isLoggedIn: $isLoggedIn'); // Debug

    if (isFirstTime) {
      return '/home'; // Rota para primeira vez (ex.: tela de onboarding)
    } else if (isLoggedIn) {
      return '/homepage'; // Rota para usuário logado
    } else {
      return '/home'; // Rota padrão (ex.: tela de login)
    }
  }
}