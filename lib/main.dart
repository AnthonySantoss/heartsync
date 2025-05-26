import 'package:flutter/material.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:heartsync/presentation/viewmodels/statistic_viewmodel.dart'; // Importe o ViewModel
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/config/routes.dart';
import 'di/injection.dart' as di; // Seu arquivo de injeção de dependência
import 'package:provider/provider.dart'; // Importe o Provider
import 'package:intl/date_symbol_data_local.dart'; // ADICIONADO: Para formatação de data localizada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa tudo na ordem correta
  final prefs = await SharedPreferences.getInstance();
  // Garante que a injeção de dependência seja inicializada.
  // É crucial que StatisticViewModel e suas dependências estejam registrados em di.init().
  await di.init();
  // Garante que o banco de dados seja inicializado antes de rodar o app.
  await DatabaseHelper.instance.database;

  // ADICIONADO: Inicializar dados de localização para o pacote intl
  // Isso permite que DateFormat('E', 'pt_BR') funcione corretamente para os dias da semana.
  await initializeDateFormatting('pt_BR', null);

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Envolve o MaterialApp com MultiProvider para disponibilizar os ViewModels
    // para a árvore de widgets.
    return MultiProvider(
      providers: [
        // Registra o StatisticViewModel. Qualquer widget descendente poderá acessá-lo
        // usando Provider.of<StatisticViewModel>(context) ou context.watch/read<StatisticViewModel>().
        ChangeNotifierProvider(create: (_) => di.sl<StatisticViewModel>()),
        // Adicione outros providers/viewmodels globais aqui se necessário.
        // Ex: ChangeNotifierProvider(create: (_) => di.sl<AuthViewModel>()),
      ],
      child: MaterialApp(
        title: 'HeartSync',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink).copyWith(
            secondary: Colors.pinkAccent, // Cor secundária para elementos como FABs
          ),
          // Você pode adicionar mais customizações de tema aqui (fontes, temas de botões, etc.)
        ),
        debugShowCheckedModeBanner: false, // Opcional: remove o banner de debug da UI.
        initialRoute: _getInitialRoute(), // Define a rota inicial baseada na lógica de estado.
        routes: AppRoutes.getRoutes(prefs), // Define as rotas nomeadas da aplicação.
        onUnknownRoute: AppRoutes.onUnknownRoute, // Define uma rota para caminhos não encontrados.
      ),
    );
  }

  // Determina a rota inicial da aplicação baseado no estado de login e primeira vez.
  String _getInitialRoute() {
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('Initial Route Check - isFirstTime: $isFirstTime, isLoggedIn: $isLoggedIn');

    if (isFirstTime) {
      // Se for a primeira vez, geralmente direciona para uma tela de introdução/onboarding
      // ou para a tela de login/registro.
      // É comum setar 'isFirstTime' para false após o onboarding.
      // Ex: prefs.setBool('isFirstTime', false); (em outra parte do código, após o onboarding)
      return AppRoutes.home; // Usando constante de rota se definida em AppRoutes.
    } else if (isLoggedIn) {
      // Se o usuário já fez login e não é a primeira vez, direciona para a homepage.
      return AppRoutes.homePage; // Usando constante de rota se definida.
    } else {
      // Se não for a primeira vez e não estiver logado, direciona para a tela de login.
      return AppRoutes.home; // Usando constante de rota se definida.
    }
  }
}