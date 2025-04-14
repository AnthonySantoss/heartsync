import 'package:flutter/material.dart';
import 'package:heartsync/Introducao.dart';
import 'package:heartsync/Login_screen .dart';

main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Login_screen(),
    );
  }
}

