/*import 'package:flutter/material.dart';
import 'package:heartsync/src/features/Registro/presentation/view/Registration_screen.dart';
import 'package:heartsync/src/features/login/presentation/view/Login_screen.dart';


class Home_screen extends StatelessWidget {
  const Home_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/images/home.png'),
              fit: BoxFit.cover,
            ),
          ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Color(0xFF1E1338),
                Color(0xFF08050F),
              ],
              stops: [0.0, 0.2, 0.8, 1.0],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const SizedBox(height: 10),
              const Text(
                'HeartSync',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Sincronize os seus corações',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Registration_screen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7D48FE),
                    minimumSize: const Size(356, 59),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Registrar',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF352756),
                    minimumSize: const Size(356, 59),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ao criar uma conta, você concorda com os nossos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Termos de Serviço',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' e ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          ' Política de Privacidade.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
} */
import 'package:flutter/material.dart';
import 'package:heartsync/db/database_helper.dart';

class Home_screen extends StatefulWidget {
  @override
  _Home_screenState createState() => _Home_screenState();
}

class _Home_screenState extends State<Home_screen> {
  final _mensagemController = TextEditingController();
  List<Map<String, dynamic>> _mensagens = [];

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
  }

  Future<void> _carregarMensagens() async {
    final dados = await DatabaseHelper.instance.getTests();
    setState(() {
      _mensagens = dados;
    });
  }

  Future<void> _salvarMensagem() async {
    final texto = _mensagemController.text.trim();
    if (texto.isEmpty) return;

    await DatabaseHelper.instance.insertTest(texto);
    _mensagemController.clear();
    await _carregarMensagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HeartSync - SQLite Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _mensagemController,
              decoration: InputDecoration(
                labelText: 'Escreva uma mensagem',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _salvarMensagem,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _mensagens.isEmpty
                  ? Center(child: Text('Nenhuma mensagem salva'))
                  : ListView.builder(
                itemCount: _mensagens.length,
                itemBuilder: (context, index) {
                  final msg = _mensagens[index];
                  return ListTile(
                    title: Text(msg['mensagem']),
                    subtitle: Text(msg['data']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
