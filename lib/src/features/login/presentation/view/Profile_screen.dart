import 'package:flutter/material.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import 'package:heartsync/src/features/Menu/presentation/view/statistic_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName1;
  final String heartCode1;
  final String birthDate1;
  final String userName2;
  final String heartCode2;
  final String birthDate2;
  final String anniversaryDate;
  final String syncDate;
  final String? imageUrl1; // Add this for user 1 image
  final String? imageUrl2; // Add this for user 2 image

  const ProfileScreen({
    super.key,
    this.userName1 = 'Isabela',
    this.heartCode1 = '#543823332PA',
    this.birthDate1 = '12.03.2004',
    this.userName2 = 'Ricardo',
    this.heartCode2 = '#123456789AB',
    this.birthDate2 = '07.08.2003',
    this.anniversaryDate = '15.05.2019',
    this.syncDate = '01.02.2025',
    this.imageUrl1, // Initialize as null
    this.imageUrl2, // Initialize as null
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(0),
                decoration: const BoxDecoration(
                  color: Color(0xFF210E45),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Image.asset(
                            'lib/assets/images/Back.png',
                            width: 27,
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Perfil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            //O back
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFFDBDBDB),
                          backgroundImage: imageUrl1 != null
                              ? NetworkImage(imageUrl1!)
                              : null,
                          child: imageUrl1 == null
                              ? const Icon(
                              Icons.person,
                              size: 120,
                              color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 1),
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFF484848),
                          backgroundImage: imageUrl2 != null
                              ? NetworkImage(imageUrl2!)
                              : null,
                          child: imageUrl2 == null
                              ? const Icon(
                              Icons.person,
                              size: 120,
                              color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Image(
                          image: AssetImage('lib/assets/images/logo.png'),
                          width: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          userName2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          heartCode1,
                          style: const TextStyle(
                            color: Color(0xFF5F38BE),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          heartCode2,
                          style: const TextStyle(
                            color: Color(0xFF5F38BE),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF210E45),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                birthDate1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Aniversário',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '|',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 20,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                birthDate2,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Aniversário',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(30),
                      width: 416,
                      decoration: BoxDecoration(
                        color: const Color(0xFF210E45),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            anniversaryDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Nosso aniversário',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: 416,
                      height: 97,
                      decoration: BoxDecoration(
                        color: const Color(0xFF210E45),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            syncDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Sincronizados desde',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
