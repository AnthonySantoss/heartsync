import 'package:flutter/material.dart';

class Login extends StatelessWidget{
  const Login({super.key});

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
            const SizedBox(height: 73),
            Image.asset(
              'assets/images/logo.png',
              width: 47.7,
            ),
          const SizedBox(height: 30),
            DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  height: 1.2
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Entrar'),
                  ],
                ),
            ),
            const SizedBox(height: 8),
            DefaultTextStyle(
                style:const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    height: 1.2
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Entre com a sua conta'),
                  ],
                ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 355,
              height: 66,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'E-mail ou HeartCode',
                  labelStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),


                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Color(0xFF4D3192),
                      width: 2.0,
                    ),
                  ),


                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 355,
              height: 66,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),


                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Color(0xFF4D3192),
                      width: 2.0,
                    ),
                  ),


                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.only(left: 150),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Esqueceu a sua senha?',
                  style: TextStyle(
                    fontSize: 18, // 18px
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
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
                const Text('Entrar',
                  style: TextStyle(fontSize: 20, fontWeight:  FontWeight.bold, color: Color(0xFFFFFFFF)),
                )
            ),
            const SizedBox(height: 30),
            DefaultTextStyle(
              style:const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  height: 1.2
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        text: 'Não possui uma conta? ',
                        children: [
                          TextSpan(
                            text: 'Registrar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

        ),
      ),
    );

  }
}