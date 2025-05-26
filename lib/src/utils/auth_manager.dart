import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _tokenKey = 'auth_token';
  static const String _serverIdKey = 'server_id';
  static const String _localIdKey = 'local_id';
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _photoUrlKey = 'photo_url';

  static Future<void> saveSessionData({
    required String token,
    required String serverId,
    required int localId,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    print('AuthManager: Salvando dados da sessão para email: $email');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_serverIdKey, serverId);
    await prefs.setInt(_localIdKey, localId);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    if (photoUrl != null) {
      await prefs.setString(_photoUrlKey, photoUrl);
    } else {
      await prefs.remove(_photoUrlKey);
    }
    print('AuthManager: Dados da sessão salvos com sucesso');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('AuthManager: Token obtido: $token');
    return token;
  }

  static Future<String?> getServerId() async {
    final prefs = await SharedPreferences.getInstance();
    final serverId = prefs.getString(_serverIdKey);
    print('AuthManager: serverId obtido: $serverId');
    return serverId;
  }

  static Future<int?> getLocalId() async {
    final prefs = await SharedPreferences.getInstance();
    final localId = prefs.getInt(_localIdKey);
    print('AuthManager: localId obtido: $localId');
    return localId;
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);
    print('AuthManager: Nome obtido: $name');
    return name;
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    print('AuthManager: Email obtido: $email');
    return email;
  }

  static Future<String?> getPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final photoUrl = prefs.getString(_photoUrlKey);
    print('AuthManager: PhotoUrl obtido: $photoUrl');
    return photoUrl;
  }

  static Future<void> clearSessionData() async {
    print('AuthManager: Limpando dados da sessão');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_serverIdKey);
    await prefs.remove(_localIdKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_photoUrlKey);
    print('AuthManager: Dados da sessão limpos');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getString(_tokenKey) != null;
    print('AuthManager: Verificando se está logado: $loggedIn');
    return loggedIn;
  }

  static Future<void> clearSession() async {
    await clearSessionData();
    print('AuthManager: Sessão finalizada');
  }
}