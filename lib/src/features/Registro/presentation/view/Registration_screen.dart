import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';

// Formatter para adicionar barras automaticamente no formato dd / mm / aaaa
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), ''); // Remove tudo exceto números
    final length = text.length;

    String newText = '';
    if (length > 0) {
      newText += text.substring(0, length > 2 ? 2 : length); // Dia
    }
    if (length > 2) {
      newText += ' / ';
      newText += text.substring(2, length > 4 ? 4 : length); // Mês
    }
    if (length > 4) {
      newText += ' / ';
      newText += text.substring(4, length > 8 ? 8 : length); // Ano
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// Tela 1: Campo Nome
class Registration_screen extends StatefulWidget {
  const Registration_screen({super.key});

  @override
  Registration_screenState createState() => Registration_screenState();
}

class Registration_screenState extends State<Registration_screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BirthScreen(name: _nameController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BackgroundWidget(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 79.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Image.asset(
                        'lib/assets/images/Back.png',
                        width: 27,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'lib/assets/images/logo.png',
                          width: 47.7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 47),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Seu nome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700, // Bold
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    filled: true,
                    fillColor: Colors.grey[900]!.withValues(alpha: 0.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFF4D3192),
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400, // Book (Regular)
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(double.infinity, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700, // Bold
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 350),
              Text.rich(
                TextSpan(
                  text: 'Já possui uma conta?',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400, // Book (Regular)
                  ),
                  children: [
                    TextSpan(
                      text: ' Entrar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700, // Bold
                        color: Colors.white,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Adicione a lógica para navegar para a tela de login
                        },
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

// Tela 2: Campo Data de Nascimento
class BirthScreen extends StatefulWidget {
  final String name;

  const BirthScreen({super.key, required this.name});

  @override
  BirthScreenState createState() => BirthScreenState();
}

class BirthScreenState extends State<BirthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _birthController = TextEditingController();

  @override
  void dispose() {
    _birthController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CredentialsScreen(
            name: widget.name,
            birth: _birthController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BackgroundWidget(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 79.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Image.asset(
                        'lib/assets/images/Back.png',
                        width: 27,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'lib/assets/images/logo.png',
                          width: 47.7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 47),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Seu aniversário',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _birthController,
                  decoration: InputDecoration(
                    labelText: 'dd / mm / aaaa',
                    labelStyle: const TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    filled: true,
                    fillColor: Colors.grey[900]!.withValues(alpha: 0.5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFF4D3192),
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    DateInputFormatter(),
                  ],
                  maxLength: 14,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua data de nascimento';
                    }
                    if (!RegExp(r'^\d{2} / \d{2} / \d{4}$').hasMatch(value)) {
                      return 'Formato inválido (dd / mm / aaaa)';
                    }
                    // Validação adicional para data válida
                    final parts = value.split(' / ');
                    final day = int.tryParse(parts[0]) ?? 0;
                    final month = int.tryParse(parts[1]) ?? 0;
                    final year = int.tryParse(parts[2]) ?? 0;

                    if (day < 1 || day > 31) {
                      return 'Dia inválido (01-31)';
                    }
                    if (month < 1 || month > 12) {
                      return 'Mês inválido (01-12)';
                    }
                    if (year < 1900 || year > DateTime.now().year) {
                      return 'Ano inválido (1900-${DateTime.now().year})';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(double.infinity, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700, // Bold
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 350),
              Text.rich(
                TextSpan(
                  text: 'Já possui uma conta?',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400, // Book (Regular)
                  ),
                  children: [
                    TextSpan(
                      text: ' Entrar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700, // Bold
                        color: Colors.white,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Adicione a lógica para navegar para a tela de login
                        },
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

// Tela 3: Campos E-mail, Senha e Confirmação de Senha
class CredentialsScreen extends StatefulWidget {
  final String name;
  final String birth;

  const CredentialsScreen({super.key, required this.name, required this.birth});

  @override
  CredentialsScreenState createState() => CredentialsScreenState();
}

class CredentialsScreenState extends State<CredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Aqui você pode adicionar a lógica para registrar o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro concluído!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BackgroundWidget(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 79.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Image.asset(
                        'lib/assets/images/Back.png',
                        width: 27,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'lib/assets/images/logo.png',
                          width: 47.7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 47),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Insira um e-mail e uma senha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo E-mail
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        filled: true,
                        fillColor: Colors.grey[900]!.withValues(alpha: 0.5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF4D3192),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu e-mail';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Campo Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        filled: true,
                        fillColor: Colors.grey[900]!.withValues(alpha: 0.5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF4D3192),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Campo Confirmação de Senha
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        labelStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        filled: true,
                        fillColor: Colors.grey[900]!.withValues(alpha: 0.5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF4D3192),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400, // Book (Regular)
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme sua senha';
                        }
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 105),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D48FE),
                  minimumSize: const Size(double.infinity, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Registrar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700, // Bold
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 140),
              Text.rich(
                TextSpan(
                  text: 'Já possui uma conta?',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400, // Book (Regular)
                  ),
                  children: [
                    TextSpan(
                      text: ' Entrar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700, // Bold
                        color: Colors.white,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Adicione a lógica para navegar para a tela de login
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}