import 'package:flutter/material.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/presentation/viewmodels/statistic_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/config/routes.dart';
import 'di/injection.dart' as di; // Seu arquivo de injeção de dependência
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Para formatação de data localizada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Inicializa a injeção de dependências
  try {
    await di.init();
    print('Dependências registradas com sucesso no GetIt');
  } catch (e) {
    print('Erro ao inicializar dependências: $e');
    // Fallback ou tratamento de erro, se necessário
  }

  // Inicializa o banco de dados
  try {
    await DatabaseHelper.instance.database;
    print('Banco de dados inicializado com sucesso');
  } catch (e) {
    print('Erro ao inicializar o banco de dados: $e');
  }

  // Inicializa dados de localização para o pacote intl
  await initializeDateFormatting('pt_BR', null);

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Registra o StatisticViewModel usando o GetIt
        ChangeNotifierProvider(create: (_) => di.sl<StatisticViewModel>()),
        // Adicione outros providers globais aqui, se necessário
        // Exemplo: ChangeNotifierProvider(create: (_) => di.sl<AuthViewModel>()),
      ],
      child: MaterialApp(
        title: 'HeartSync',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink).copyWith(
            secondary: Colors.pinkAccent,
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: _getInitialRoute(),
        routes: AppRoutes.getRoutes(prefs),
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }

  // Determina a rota inicial da aplicação baseado no estado de login e primeira vez
  String _getInitialRoute() {
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('Initial Route Check - isFirstTime: $isFirstTime, isLoggedIn: $isLoggedIn');

    if (isFirstTime) {
      // Direciona para a tela de introdução/onboarding
      return AppRoutes.intro; // Ajuste para a rota de introdução, se diferente
    } else if (isLoggedIn) {
      // Direciona para a homepage se o usuário estiver logado
      return AppRoutes.homePage;
    } else {
      // Direciona para a tela de login se não estiver logado
      return AppRoutes.login;
    }
  }
}