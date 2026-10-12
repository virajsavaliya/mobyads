import 'dart:io';

/// Google AdMob Test Ad Unit IDs
/// Official test IDs provided by Google for testing ads in debug mode:
/// https://developers.google.com/admob/android/test-ads
/// https://developers.google.com/admob/ios/test-ads
class AdConstants {
  AdConstants._();

  // Android Test Ad Unit IDs
  static const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String androidRewardedInterstitialAdUnitId = 'ca-app-pub-3940256099942544/5354046379';
  static const String androidNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
  static const String androidAppOpenAdUnitId = 'ca-app-pub-3940256099942544/9257395921';

  // iOS Test Ad Unit IDs
  static const String iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
  static const String iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';
  static const String iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
  static const String iosRewardedInterstitialAdUnitId = 'ca-app-pub-3940256099942544/6978759866';
  static const String iosNativeAdUnitId = 'ca-app-pub-3940256099942544/3986624511';
  static const String iosAppOpenAdUnitId = 'ca-app-pub-3940256099942544/5575463023';

  // Platform-aware getters
  static String get bannerAdUnitId =>
      Platform.isAndroid ? androidBannerAdUnitId : iosBannerAdUnitId;

  static String get interstitialAdUnitId =>
      Platform.isAndroid ? androidInterstitialAdUnitId : iosInterstitialAdUnitId;

  static String get rewardedAdUnitId =>
      Platform.isAndroid ? androidRewardedAdUnitId : iosRewardedAdUnitId;

  static String get rewardedInterstitialAdUnitId =>
      Platform.isAndroid ? androidRewardedInterstitialAdUnitId : iosRewardedInterstitialAdUnitId;

  static String get nativeAdUnitId =>
      Platform.isAndroid ? androidNativeAdUnitId : iosNativeAdUnitId;

  static String get appOpenAdUnitId =>
      Platform.isAndroid ? androidAppOpenAdUnitId : iosAppOpenAdUnitId;
}
