import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/data/models/user_model.dart';

class ApiService {
  final String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? "http://192.168.0.8:3000";

  String getBaseUrl() => _baseUrl;

  Exception _handleHttpError(http.Response response, String operation) {
    try {
      final errorBody = jsonDecode(response.body);
      return Exception(errorBody['message'] ?? 'Erro em $operation: ${response.statusCode}');
    } catch (e) {
      String responseBodySnippet = response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      return Exception('Erro em $operation (HTTP ${response.statusCode}). Resposta: $responseBodySnippet');
    }
  }

  Exception _handleGenericError(dynamic e, String operation) {
    if (e is SocketException) {
      return Exception('Erro de conexão em $operation. Verifique sua internet ou se o servidor ($_baseUrl) está acessível.');
    } else if (e is http.ClientException) {
      return Exception('Erro de cliente HTTP em $operation: ${e.message}');
    } else if (e is Exception) {
      return e;
    }
    return Exception('Ocorreu um erro inesperado durante $operation: $e');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    const String operation = "login";
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('user') && responseData['user'] is Map<String, dynamic>) {
          final userDataFromServer = responseData['user'] as Map<String, dynamic>;
          final serverId = userDataFromServer['_id'] as String?;
          if (serverId == null) throw Exception('ID do usuário (serverId) não retornado pelo backend no login.');
          responseData['serverId'] = serverId;
        } else {
          throw Exception('Dados do usuário não retornados corretamente pelo backend no login.');
        }
        return responseData;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> registrationData) async {
    const String operation = "registro";
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registrationData),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('user') && responseData['user'] is Map<String, dynamic>) {
          final userDataFromServer = responseData['user'] as Map<String, dynamic>;
          final serverId = userDataFromServer['_id'] as String?;
          if (serverId == null) throw Exception('ID do usuário (serverId) não retornado pelo backend no registro.');
          responseData['serverId'] = serverId;
        } else {
          throw Exception('Dados do usuário não retornados corretamente pelo backend no registro.');
        }
        return responseData;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<UserModel> getMyProfile() async {
    const String operation = "buscar perfil";
    String? token = await AuthManager.getToken();
    if (token == null) throw Exception('Usuário não autenticado. Token não encontrado para $operation.');

    final url = Uri.parse('$_baseUrl/users/me');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic>) {
          return UserModel.fromJson(responseBody);
        } else {
          throw Exception('Formato inesperado da resposta do perfil. Esperava Map, recebeu ${responseBody.runtimeType}');
        }
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    const String operation = "atualizar perfil";
    String? token = await AuthManager.getToken();
    String? serverId = await AuthManager.getServerId();

    if (token == null) throw Exception('Usuário não autenticado para $operation.');
    if (serverId == null) throw Exception('ID do servidor não encontrado para $operation.');

    final url = Uri.parse('$_baseUrl/users/$serverId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode(profileData),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  // Novo método para upload de imagem usando a rota /upload
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    const String operation = "upload de imagem";
    final url = Uri.parse('$_baseUrl/upload');

    try {
      var request = http.MultipartRequest('POST', url);

      String fileName = imageFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      MediaType? contentType;
      if (['jpg', 'jpeg'].contains(fileExtension)) {
        contentType = MediaType('image', 'jpeg');
      } else if (fileExtension == 'png') {
        contentType = MediaType('image', 'png');
      }

      request.files.add(await http.MultipartFile.fromPath(
        'profile_image', // Nome do campo esperado pelo servidor
        imageFile.path,
        filename: fileName,
        contentType: contentType,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('imageUrl') && responseData['imageUrl'] != null) {
          return responseData;
        } else {
          throw Exception("Resposta de upload de imagem inválida: 'imageUrl' ausente.");
        }
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(String serverId, File imageFile) async {
    const String operation = "upload foto de perfil";
    String? token = await AuthManager.getToken();

    if (token == null) {
      throw Exception('Usuário não autenticado. Token não encontrado para $operation.');
    }

    final url = Uri.parse('$_baseUrl/users/$serverId/avatar');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      String fileName = imageFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      MediaType? contentType;
      if (['jpg', 'jpeg'].contains(fileExtension)) {
        contentType = MediaType('image', 'jpeg');
      } else if (fileExtension == 'png') {
        contentType = MediaType('image', 'png');
      }

      request.files.add(await http.MultipartFile.fromPath(
        'avatarFile',
        imageFile.path,
        filename: fileName,
        contentType: contentType,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('filePath') && responseData['filePath'] != null) {
          return responseData;
        } else {
          throw Exception("Resposta de upload de foto inválida: 'filePath' ausente.");
        }
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    const String operation = "enviar código de verificação";
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-verification-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    const String operation = "verificar código";
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<void> deleteAccount() async {
    const String operation = "deletar conta";
    String? token = await AuthManager.getToken();
    String? serverId = await AuthManager.getServerId();

    if (token == null) throw Exception('Usuário não autenticado para $operation.');
    if (serverId == null) throw Exception('ID do servidor não encontrado para $operation.');

    final url = Uri.parse('$_baseUrl/users/$serverId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }
}