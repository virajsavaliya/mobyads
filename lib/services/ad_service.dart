import '../core/utils/app_logger.dart';

/// AdService mock / simulation provider
class AdService {
  static Future<void> initialize() async {
    AppLogger.i('AdService initialized successfully');
  }

  void loadRewardedAd({required Function() onAdLoaded, Function(dynamic)? onAdFailedToLoad}) {
    onAdLoaded();
  }

  void showRewardedAd({
    required Function(dynamic reward) onUserEarnedReward,
    Function()? onAdDismissed,
  }) {
    onUserEarnedReward(150);
    onAdDismissed?.call();
  }

  void loadInterstitialAd({Function()? onAdLoaded}) {
    onAdLoaded?.call();
  }

  void showInterstitialAd({Function()? onAdDismissed}) {
    onAdDismissed?.call();
  }
}
