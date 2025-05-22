import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl; // Tornando o baseUrl configurável
  static const String defaultBaseUrl = 'http://localhost:3000';

  ApiService({this.baseUrl = defaultBaseUrl});

  // Método para buscar dados (GET)
  Future<dynamic> fetchData(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      if (response.statusCode == 200) {
        print('Fetch data from $endpoint: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch data from $endpoint: Status ${response.statusCode}, Body ${response.body}');
        throw Exception('Failed to fetch data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Network error: $e');
    }
  }

  // Método para enviar código de verificação (POST)
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-verification-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('Send verification code response: Status ${response.statusCode}, Body ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to send verification code: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending verification code: $e');
      throw Exception('Network error: $e');
    }
  }

  // Método para criar usuário (POST)
  Future<Map<String, dynamic>> createUsuario({
    required String nome,
    required String email,
    required String dataNascimento,
    required String senha,
    bool temFoto = false,
    String? profileImagePath,
  }) async {
    try {
      final body = {
        'nome': nome.trim(),
        'email': email.trim(),
        'dataNascimento': dataNascimento,
        'senha': senha.trim(),
        'temFoto': temFoto,
        'profileImagePath': profileImagePath,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Create user response: Status ${response.statusCode}, Body ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Network error: $e');
    }
  }
}