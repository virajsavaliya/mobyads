import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/config/ad_config.dart';
import '../../../core/utils/app_logger.dart';

/// Reusable Google Mobile Ads Banner Widget.
/// Uses [AdConfig.bannerAdUnitId] to load test or production banners.
class AppBannerAd extends StatefulWidget {
  final AdSize adSize;
  final VoidCallback? onAdLoaded;
  final void Function(LoadAdError error)? onAdFailedToLoad;

  const AppBannerAd({
    super.key,
    this.adSize = AdSize.banner,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initBannerAd();
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AppLogger.d('Banner ad loaded: ${ad.adUnitId}');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
            widget.onAdLoaded?.call();
          }
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.e('Banner ad failed to load: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
            widget.onAdFailedToLoad?.call(error);
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
