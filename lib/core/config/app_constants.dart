/// Application-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'MobyAds';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = '₹';
  static const String pointsName = 'Coins';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Storage Keys
  static const String tokenKey = 'mobyads_auth_token';
  static const String refreshTokenKey = 'mobyads_refresh_token';
  static const String userKey = 'mobyads_user_data';
  static const String themeKey = 'mobyads_theme_mode';
  static const String onboardingKey = 'mobyads_onboarding_completed';
}
