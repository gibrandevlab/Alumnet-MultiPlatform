import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'token';
  static const _userIdKey = 'userId';
  static const _loginTimeKey = 'loginTime';

  static Future<void> saveLogin(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<Map<String, dynamic>?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getInt(_userIdKey);
    final loginTime = prefs.getInt(_loginTimeKey);
    if (token != null && userId != null && loginTime != null) {
      return {
        'token': token,
        'userId': userId,
        'loginTime': loginTime,
      };
    }
    return null;
  }

  static Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_loginTimeKey);
  }
}
