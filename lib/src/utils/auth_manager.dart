import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _tokenKey = 'authToken';
  static const String _serverIdKey = 'serverId';
  static const String _localIdKey = 'localId';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userPhotoUrlKey = 'userPhotoUrl';
  static const String _lastLoginKey = 'lastLogin';
  static const String _isLoggedInKey = 'isLoggedIn';

  static Future<void> saveSessionData({
    required String token,
    required String serverId,
    int? localId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('AuthManager: Salvando dados da sessão - token: $token, serverId: $serverId, localId: $localId');
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_serverIdKey, serverId);
      await prefs.setBool(_isLoggedInKey, true);
      if (localId != null) await prefs.setInt(_localIdKey, localId);
      if (name != null) await prefs.setString(_userNameKey, name);
      if (email != null) await prefs.setString(_userEmailKey, email);
      if (photoUrl != null) await prefs.setString(_userPhotoUrlKey, photoUrl);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
      print('AuthManager: Dados da sessão salvos com sucesso');
    } catch (e) {
      print('AuthManager: Erro ao salvar dados da sessão: $e');
      throw Exception('Falha ao salvar dados da sessão: $e');
    }
  }

  static Future<void> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString(_userNameKey, name);
      if (email != null) await prefs.setString(_userEmailKey, email);
      if (photoUrl != null) await prefs.setString(_userPhotoUrlKey, photoUrl);
      print('AuthManager: Perfil do usuário atualizado com sucesso');
    } catch (e) {
      print('AuthManager: Erro ao atualizar perfil do usuário: $e');
      throw Exception('Falha ao atualizar perfil do usuário: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('AuthManager: Token obtido: $token');
      return token;
    } catch (e) {
      print('AuthManager: Erro ao obter token: $e');
      return null;
    }
  }

  static Future<String?> getServerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverId = prefs.getString(_serverIdKey);
      print('AuthManager: ServerId obtido: $serverId');
      return serverId;
    } catch (e) {
      print('AuthManager: Erro ao obter serverId: $e');
      return null;
    }
  }

  static Future<int?> getLocalId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localId = prefs.getInt(_localIdKey);
      print('AuthManager: LocalId obtido: $localId');
      return localId;
    } catch (e) {
      print('AuthManager: Erro ao obter localId: $e');
      return null;
    }
  }

  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString(_userNameKey);
      print('AuthManager: Nome do usuário obtido: $userName');
      return userName;
    } catch (e) {
      print('AuthManager: Erro ao obter nome do usuário: $e');
      return null;
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_userEmailKey);
      print('AuthManager: Email do usuário obtido: $email');
      return email;
    } catch (e) {
      print('AuthManager: Erro ao obter email do usuário: $e');
      return null;
    }
  }

  static Future<String?> getUserPhotoUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photoUrl = prefs.getString(_userPhotoUrlKey);
      print('AuthManager: URL da foto do usuário obtida: $photoUrl');
      return photoUrl;
    } catch (e) {
      print('AuthManager: Erro ao obter URL da foto do usuário: $e');
      return null;
    }
  }

  static Future<DateTime?> getLastLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLogin = prefs.getString(_lastLoginKey);
      print('AuthManager: Último login obtido: $lastLogin');
      return lastLogin != null ? DateTime.parse(lastLogin) : null;
    } catch (e) {
      print('AuthManager: Erro ao obter data do último login: $e');
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      print('AuthManager: Verificando status de login - token: $token, isLoggedIn: $isLoggedIn');
      if (token == null || token.isEmpty || !isLoggedIn) {
        print('AuthManager: Usuário não está logado');
        return false;
      }
      print('AuthManager: Usuário está logado');
      return true;
    } catch (e) {
      print('AuthManager: Erro ao verificar status de login: $e');
      return false;
    }
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('AuthManager: Limpando dados da sessão');
      await prefs.remove(_tokenKey);
      await prefs.remove(_serverIdKey);
      await prefs.remove(_localIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userPhotoUrlKey);
      await prefs.remove(_lastLoginKey);
      await prefs.setBool(_isLoggedInKey, false);
      print('AuthManager: Sessão limpa com sucesso');
    } catch (e) {
      print('AuthManager: Erro ao limpar sessão: $e');
      throw Exception('Falha ao limpar sessão: $e');
    }
  }
}