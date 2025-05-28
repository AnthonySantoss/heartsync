import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:heartsync/src/utils/auth_manager.dart';
import 'package:heartsync/data/models/user_model.dart';

class ApiService {
  final String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? 'http://192.168.1.14:3000';

  String getBaseUrl() => _baseUrl;

  Exception _handleHttpError(http.Response response, String operation) {
    try {
      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody['error'] ?? 'Erro desconhecido do servidor.';
      print('[_handleHttpError] Operação: $operation, Status: ${response.statusCode}, Erro: $errorMessage, Body: ${response.body}');
      return Exception('Erro em $operation (HTTP ${response.statusCode}): $errorMessage');
    } catch (e) {
      String responseBodySnippet =
      response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body;
      print('[_handleHttpError] Operação: $operation, Status: ${response.statusCode}, Body (snippet): $responseBodySnippet. Falha ao decodificar JSON do erro.');
      return Exception('Erro em $operation (HTTP ${response.statusCode}). Resposta: $responseBodySnippet');
    }
  }

  Exception _handleGenericError(dynamic e, String operation) {
    print('[_handleGenericError] Operação: $operation, Erro: $e');
    if (e is SocketException) {
      return Exception(
          'Erro de conexão em $operation. Verifique sua internet ou se o servidor ($_baseUrl) está acessível.');
    } else if (e is http.ClientException) {
      return Exception('Erro de cliente HTTP em $operation: ${e.message}');
    } else if (e is Exception) {
      return e;
    }
    return Exception('Ocorreu um erro inesperado durante $operation: $e');
  }

  Future<Map<String, String>> _getAuthHeaders({bool contentTypeJson = true}) async {
    String? token = await AuthManager.getToken();
    if (token == null) {
      print('[ApiService] ALERTA: Tentativa de obter cabeçalhos autenticados, mas o token é nulo.');
      throw Exception('Usuário não autenticado. Token não encontrado.');
    }
    final headers = {'Authorization': 'Bearer $token'};
    if (contentTypeJson) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    const String operation = 'login';
    try {
      print('[ApiService.$operation] Iniciando para email: $email');
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('user') &&
            responseData['user'] is Map<String, dynamic> &&
            responseData.containsKey('token')) {
          final userDataFromServer = responseData['user'] as Map<String, dynamic>;
          final serverId = userDataFromServer['id']?.toString() ?? userDataFromServer['_id']?.toString();
          final token = responseData['token'] as String?;

          if (serverId == null || token == null) {
            throw Exception('ID do usuário ($serverId) ou token ($token) não retornado ou nulo pelo backend no $operation.');
          }
          responseData['serverId'] = serverId;
          return responseData;
        } else {
          throw Exception('Dados do usuário ou token não retornados corretamente pelo backend no $operation.');
        }
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> registrationData) async {
    const String operation = 'registro';
    try {
      print('[ApiService.$operation] Iniciando para email: ${registrationData['email']}');
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(registrationData),
      ).timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('user') &&
            responseData['user'] is Map<String, dynamic> &&
            responseData.containsKey('token')) {
          final userDataFromServer = responseData['user'] as Map<String, dynamic>;
          final serverId = userDataFromServer['id']?.toString() ?? userDataFromServer['_id']?.toString();
          final token = responseData['token'] as String?;

          if (serverId == null || token == null) {
            throw Exception('ID do usuário ($serverId) ou token ($token) não retornado ou nulo pelo backend no $operation.');
          }
          responseData['serverId'] = serverId;
          return responseData;
        } else {
          throw Exception('Dados do usuário ou token não retornados corretamente pelo backend no $operation.');
        }
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<UserModel> getMyProfile() async {
    const String operation = 'buscar perfil';
    final url = Uri.parse('$_baseUrl/users/me');
    try {
      print('[ApiService.$operation] Buscando perfil do usuário');
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('_id') && responseBody['id'] == null) {
            responseBody['id'] = responseBody['_id'];
          }
          return UserModel.fromJson(responseBody);
        } else {
          throw Exception(
              'Formato inesperado da resposta do perfil. Esperava Map, recebeu ${responseBody.runtimeType}');
        }
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    const String operation = 'buscar perfil do usuário';
    final url = Uri.parse('$_baseUrl/users/me');
    try {
      print('[ApiService.$operation] Buscando perfil do usuário');
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));

      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        return responseBody;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    const String operation = 'atualizar perfil';
    String? serverId = await AuthManager.getServerId();
    if (serverId == null) throw Exception('ID do servidor (usuário) não encontrado para $operation.');

    final url = Uri.parse('$_baseUrl/users/$serverId');
    try {
      print('[ApiService.$operation] Atualizando perfil do usuário $serverId');
      final headers = await _getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(profileData),
      ).timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    const String operation = 'upload de imagem (genérico)';
    final url = Uri.parse('$_baseUrl/upload');
    try {
      print('[ApiService.$operation] Iniciando upload de imagem: ${imageFile.path}');
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
        'profile_image',
        imageFile.path,
        filename: fileName,
        contentType: contentType,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('imageUrl') && responseData['imageUrl'] != null) {
          return responseData;
        } else {
          throw Exception("Resposta de $operation inválida: 'imageUrl' ausente.");
        }
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(String serverId, File imageFile) async {
    const String operation = 'upload foto de perfil';
    String? currentServerId = await AuthManager.getServerId();
    if (currentServerId == null) throw Exception('ID do servidor (usuário) não encontrado para $operation.');
    if (serverId != currentServerId) {
      print('[ApiService.$operation] ALERTA: serverId fornecido ($serverId) é diferente do serverId do AuthManager ($currentServerId). Usando o do AuthManager.');
    }

    final url = Uri.parse('$_baseUrl/users/$currentServerId/avatar');
    try {
      print('[ApiService.$operation] Iniciando upload para serverId: $currentServerId, Arquivo: ${imageFile.path}');
      final headers = await _getAuthHeaders(contentTypeJson: false);
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

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

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('filePath') && responseData['filePath'] != null) {
          return responseData;
        } else {
          throw Exception("Resposta de $operation inválida: 'filePath' ausente.");
        }
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    const String operation = 'enviar código de verificação';
    try {
      print('[ApiService.$operation] Enviando para email: $email');
      final response = await http.post(
        Uri.parse('$_baseUrl/send-verification-code'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

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
    const String operation = 'verificar código';
    try {
      print('[ApiService.$operation] Verificando para email: $email, code: $code');
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-code'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'code': code}),
      ).timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

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
    const String operation = 'deletar conta';
    String? serverId = await AuthManager.getServerId();
    if (serverId == null) throw Exception('ID do servidor (usuário) não encontrado para $operation.');

    final url = Uri.parse('$_baseUrl/users/$serverId');
    try {
      print('[ApiService.$operation] Deletando conta para serverId: $serverId');
      final headers = await _getAuthHeaders(contentTypeJson: false);
      final response = await http.delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[ApiService.$operation] Conta deletada com sucesso.');
        return;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<Map<String, dynamic>> saveRouletteActivity({
    required int userId,
    required String dataRoleta,
    required String atividade,
    required String blockTime,
    required String proximaRoleta,
  }) async {
    const String operation = 'salvar atividade da roleta';
    String? loggedInUserServerId = await AuthManager.getServerId();
    int? loggedInUserId = loggedInUserServerId != null ? int.tryParse(loggedInUserServerId) : null;

    if (loggedInUserId == null || userId != loggedInUserId) {
      print('[ApiService.$operation] ALERTA: Tentativa de salvar atividade da roleta para userId ($userId) que não corresponde ao usuário logado ($loggedInUserId).');
    }

    try {
      print('[ApiService.$operation] Salvando atividade da roleta para userId: $userId');
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/roulette/save'),
        headers: headers,
        body: jsonEncode({
          'userId': userId,
          'dataRoleta': dataRoleta,
          'atividade': atividade,
          'blockTime': blockTime,
          'proximaRoleta': proximaRoleta,
        }),
      ).timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<void> resetStreak(int userId) async {
    const String operation = 'resetar sequência';
    String? loggedInUserServerId = await AuthManager.getServerId();
    int? loggedInUserId = loggedInUserServerId != null ? int.tryParse(loggedInUserServerId) : null;

    if (loggedInUserId == null || userId != loggedInUserId) {
      print('[ApiService.$operation] ALERTA: Tentativa de resetar streak para userId ($userId) que não corresponde ao usuário logado ($loggedInUserId).');
    }

    try {
      print('[ApiService.$operation] Resetando sequência para userId: $userId');
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/roulette/reset-streak'),
        headers: headers,
        body: jsonEncode({'userId': userId}),
      ).timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<void> updateStreak(int userId, int streak, {String? lastStreakDate}) async {
    const String operation = 'atualizar sequência';
    String? loggedInUserServerId = await AuthManager.getServerId();
    int? loggedInUserId = loggedInUserServerId != null ? int.tryParse(loggedInUserServerId) : null;

    if (loggedInUserId == null || userId != loggedInUserId) {
      print('[ApiService.$operation] ALERTA: Tentativa de atualizar streak para userId ($userId) que não corresponde ao usuário logado ($loggedInUserId).');
    }

    try {
      print('[ApiService.$operation] Atualizando sequência para userId: $userId, streak: $streak');
      final headers = await _getAuthHeaders();
      final body = {
        'userId': userId,
        'streak': streak,
        if (lastStreakDate != null) 'lastStreakDate': lastStreakDate,
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/roulette/update-streak'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      throw _handleGenericError(e, operation);
    }
  }

  Future<int> getStreak(int userId) async {
    const String operation = 'recuperar sequência';
    String? token = await AuthManager.getToken();

    if (token == null) {
      print('[ApiService.$operation] ALERTA: Token é nulo. Não é possível fazer a chamada autenticada.');
      throw Exception('Usuário não autenticado. Token não encontrado para $operation.');
    }

    try {
      print('[ApiService.$operation] Recuperando sequência para userId: $userId');
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/roulette/streak/$userId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('[ApiService.$operation] Resposta recebida: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return responseData['streak'] as int? ?? 0;
      } else if (response.statusCode == 403) {
        print('[ApiService.$operation] ERRO 403 (Acesso Não Autorizado) para userId $userId.');
        throw Exception('Acesso não autorizado (403) ao buscar sequência.');
      } else {
        throw _handleHttpError(response, operation);
      }
    } catch (e) {
      print('[ApiService.$operation] Exceção capturada: $e');
      throw _handleGenericError(e, operation);
    }
  }
}