import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Menu/presentation/view/statistic_screen.dart';
import 'package:heartsync/src/features/Roleta/presentation/view/Roulette_screen.dart';
import 'package:heartsync/src/features/home/presentation/view/Home_screen.dart';
import 'package:heartsync/src/features/login/presentation/view/Profile_screen.dart';

import 'Introducao.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RouletteScreen(),
    );
  }
}

