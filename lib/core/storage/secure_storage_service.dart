import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';

/// Service wrapper for key-value token and preferences storage
class SecureStorageService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<void> clearAuthTokens() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
  }

  Future<void> write(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String?> read(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> delete(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  Future<void> deleteAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
