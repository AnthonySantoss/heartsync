import 'package:flutter/material.dart';
import 'package:heartsync/Introducao.dart';
import 'package:heartsync/src/features/login/presentation/view/Registration_screen.dart';

main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Registration_screen(),
    );
  }
}

