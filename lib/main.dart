import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heartsync/src/config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: _getInitialRoute(),
      routes: AppRoutes.getRoutes(prefs),
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }

  String _getInitialRoute() {
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('Initial Route - isFirstTime: $isFirstTime, isLoggedIn: $isLoggedIn'); // Debug
    if (isFirstTime) {
      return '/home';
    } else if (isLoggedIn) {
      return '/homepage';
    } else {
      return '/home';
    }
  }
}