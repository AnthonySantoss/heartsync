import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:heartsync/presentation/viewmodels/heart_code_qr_viewmodel.dart';
import 'package:heartsync/src/features/login/presentation/widgets/Background_widget.dart';
import '../../../../../di/injection.dart' as di;

class HeartCodeQRScreen extends StatelessWidget {
  final String name;
  final String birth;
  final String email;
  final String password;
  final String? profileImagePath;
  final VoidCallback onRegisterComplete;

  const HeartCodeQRScreen({
    super.key,
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
    this.profileImagePath,
    required this.onRegisterComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = di.sl<HeartCodeQRViewModel>();
        viewModel.generateHeartCode(
          name: name,
          birth: birth,
          email: email,
          password: password,
          profileImagePath: profileImagePath,
        );
        return viewModel;
      },
      child: Consumer<HeartCodeQRViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: BackgroundWidget(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header Section
                    _buildHeader(context),
                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'Heart Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // State Handling
                    _buildContentSection(context, viewModel),

                    // Action Button
                    _buildActionButton(context, viewModel),

                    // Login Option
                    _buildLoginOption(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 79.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('lib/assets/images/Back.png', width: 27),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset('lib/assets/images/logo.png', width: 47.7),
            ),
          ),
          const SizedBox(width: 47), // For balance
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, HeartCodeQRViewModel viewModel) {
    if (viewModel.isLoading) {
      return const CircularProgressIndicator();
    }

    if (viewModel.user != null) {
      return _buildUserInfoSection(context, viewModel); // Prioriza a exibição do QR Code e heartCode
    }

    if (viewModel.error != null) {
      return Column(
        children: [
          Text(
            viewModel.error!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => viewModel.generateHeartCode(
              name: name,
              birth: birth,
              email: email,
              password: password,
              profileImagePath: profileImagePath,
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    if (viewModel.successMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          viewModel.successMessage!,
          style: const TextStyle(color: Colors.green, fontSize: 18),
        ),
      );
    }

    return const SizedBox(); // Empty state
  }

  Widget _buildUserInfoSection(BuildContext context, HeartCodeQRViewModel viewModel) {
    return Column(
      children: [
        // QR Code Display com estilo
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFF7D48FE), width: 3),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF7D48FE).withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              viewModel.user!.qrCodeUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'Erro ao carregar o QR Code',
                  style: TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Nome do usuário
        Text(
          viewModel.user!.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Código Heart com botão de cópia
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Seu Heart Code é: ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              viewModel.user!.heartCode,
              style: const TextStyle(
                color: Color(0xFF5127A7),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF7D48FE),
              ),
              child: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: viewModel.user!.heartCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado!')),
                  );
                },
                icon: const Icon(Icons.copy, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildActionButton(BuildContext context, HeartCodeQRViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: ElevatedButton(
        onPressed: viewModel.user != null
            ? () {
          Navigator.pushNamed(
            context,
            '/heart-code-input',
            arguments: {
              'name': name,
              'birth': birth,
              'email': email,
              'password': password,
              'profileImagePath': profileImagePath,
              'heartCode': viewModel.user!.heartCode,
              'onRegisterComplete': onRegisterComplete,
            },
          );
        }
            : null,
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
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginOption(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Já possui uma conta?',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: ' Entrar',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}