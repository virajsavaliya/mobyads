import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/app_logger.dart';

/// Centralized Google Mobile Ads Configuration.
/// - Controls test vs. production ad unit routing.
/// - Registers test device IDs to protect AdMob accounts from policy violations.
/// - Offers debug flags to simulate ad failures for resilience verification.
class AdConfig {
  AdConfig._();

  /// Set to `false` when preparing official production builds for Google Play / App Store.
  static const bool useTestAds = true;

  /// Number of independent BannerAd slides in the Home Ad Carousel.
  static const int adCarouselSlideCount = 4;

  /// Debug flag to simulate ad load failures and verify fallback flows.
  static const bool simulateAdFailure = false;

  /// Registered test device IDs (MD5 hashed IDs from Xcode / Android logcat).
  /// Prevents accidental invalid traffic penalties on production-linked accounts.
  static const List<String> testDeviceIds = [
    '00008130-001250202109001C',
    '9da552674a2397db5081d5e92282fb7a', // Viraj's iPhone AdMob Test Identifier
  ];

  // Test Ad Unit IDs (Google Official Test Ad Units)
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';

  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  // Production Ad Unit IDs (Replace with your registered AdMob unit IDs)
  static const String _prodBannerAndroid = 'YOUR_PRODUCTION_ANDROID_BANNER_ID';
  static const String _prodBannerIos = 'YOUR_PRODUCTION_IOS_BANNER_ID';

  static const String _prodInterstitialAndroid = 'YOUR_PRODUCTION_ANDROID_INTERSTITIAL_ID';
  static const String _prodInterstitialIos = 'YOUR_PRODUCTION_IOS_INTERSTITIAL_ID';

  static const String _prodRewardedAndroid = 'YOUR_PRODUCTION_ANDROID_REWARDED_ID';
  static const String _prodRewardedIos = 'YOUR_PRODUCTION_IOS_REWARDED_ID';

  /// Sourced Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (useTestAds) {
      return Platform.isIOS ? _testBannerIos : _testBannerAndroid;
    }
    return Platform.isIOS ? _prodBannerIos : _prodBannerAndroid;
  }

  /// Sourced Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (useTestAds) {
      return Platform.isIOS ? _testInterstitialIos : _testInterstitialAndroid;
    }
    return Platform.isIOS ? _prodInterstitialIos : _prodInterstitialAndroid;
  }

  /// Sourced Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (useTestAds) {
      return Platform.isIOS ? _testRewardedIos : _testRewardedAndroid;
    }
    return Platform.isIOS ? _prodRewardedIos : _prodRewardedAndroid;
  }

  /// Configures test device IDs on the MobileAds SDK
  static Future<void> configureRequestConfiguration() async {
    try {
      final requestConfiguration = RequestConfiguration(
        testDeviceIds: testDeviceIds,
      );
      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      AppLogger.i('Google Mobile Ads RequestConfiguration applied with ${testDeviceIds.length} test devices.');
    } catch (e) {
      AppLogger.w('Failed to update MobileAds RequestConfiguration: $e');
    }
  }
}
