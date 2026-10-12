import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';

/// Service wrapper for SharedPreferences (non-sensitive cached state)
class SharedPrefsService {
  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  static Future<SharedPrefsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsService(prefs);
  }

  bool get isOnboardingCompleted =>
      _prefs.getBool(AppConstants.onboardingKey) ?? false;

  Future<bool> setOnboardingCompleted(bool value) =>
      _prefs.setBool(AppConstants.onboardingKey, value);

  String? get themeMode => _prefs.getString(AppConstants.themeKey);

  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.themeKey, mode);

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  double? getDouble(String key) => _prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
