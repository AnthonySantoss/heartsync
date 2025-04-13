import 'package:flutter/material.dart';

class Introducao extends StatelessWidget {
  const Introducao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E1338),
              Color(0xFF08050F),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(width: 74 + 20),
                Image.asset(
                  'assets/images/logo.png',
                  width: 74,
                ),


                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Pular'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/perfilConjunto.png',
              width: 440,
              height: 436,
            ),
            const SizedBox(height: 30),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Um app em'),
                  const SizedBox(height: 8),
                  const Text('Conjunto'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(356, 66),
                  backgroundColor: Color(0xFF7D48FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )

                ),
                child:
                const Text('Próximo',
                style: TextStyle(fontSize: 20, fontWeight:  FontWeight.bold, color: Color(0xFFFFFFFF)),
                )
            ),

          ],

        ),
      ),
    );
  }
}