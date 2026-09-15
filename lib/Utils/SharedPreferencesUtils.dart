import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static const String _keyToken = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}
