import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _tokenKey = 'authToken';
  static const String _serverIdKey = 'serverId';
  static const String _localIdKey = 'localId';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userPhotoUrlKey = 'userPhotoUrl';

  static Future<void> saveSessionData({
    required String token,
    required String serverId,
    int? localId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_serverIdKey, serverId);
    if (localId != null) await prefs.setInt(_localIdKey, localId);
    if (name != null) await prefs.setString(_userNameKey, name);
    if (email != null) await prefs.setString(_userEmailKey, email);
    if (photoUrl != null) await prefs.setString(_userPhotoUrlKey, photoUrl);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getServerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverIdKey);
  }

  static Future<int?> getLocalId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_localIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getUserPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhotoUrlKey);
  }

  static Future<void> setUserPhotoUrl(String photoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhotoUrlKey, photoUrl);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_serverIdKey);
    await prefs.remove(_localIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhotoUrlKey);
  }
}