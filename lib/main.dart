import 'package:flutter/material.dart';
import 'package:heartsync/src/features/home/presentation/view/Home_screen.dart';

import 'Introducao.dart';


main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Introducao(),
    );
  }
}

