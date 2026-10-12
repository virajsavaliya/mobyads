import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/config/ad_config.dart';

void main() {
  group('AdConfig Tests', () {
    test('Returns test ad units when useTestAds is true', () {
      expect(AdConfig.useTestAds, isTrue);
      expect(AdConfig.bannerAdUnitId, isNotEmpty);
      expect(AdConfig.interstitialAdUnitId, isNotEmpty);
      expect(AdConfig.rewardedAdUnitId, isNotEmpty);

      // Verify IDs match Google test ad formats
      expect(AdConfig.bannerAdUnitId, startsWith('ca-app-pub-3940256099942544/'));
      expect(AdConfig.interstitialAdUnitId, startsWith('ca-app-pub-3940256099942544/'));
      expect(AdConfig.rewardedAdUnitId, startsWith('ca-app-pub-3940256099942544/'));
    });
  });
}
