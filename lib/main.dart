import 'package:flutter/material.dart';
import 'package:heartsync/data/datasources/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/config/routes.dart';
import 'di/injection.dart' as di;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa tudo na ordem correta
  final prefs = await SharedPreferences.getInstance();
  await di.init(); // Injeção de dependências
  await DatabaseHelper.instance.database; // Garante que o banco está inicializado

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartSync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: _getInitialRoute(),
      routes: AppRoutes.getRoutes(prefs),
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }

  String _getInitialRoute() {
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('Initial Route - isFirstTime: $isFirstTime, isLoggedIn: $isLoggedIn');

    if (isFirstTime) {
      return '/home';
    } else if (isLoggedIn) {
      return '/homepage';
    } else {
      return '/home';
    }
  }
}