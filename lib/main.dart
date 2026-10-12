import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/config/ad_config.dart';
import 'core/config/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ads are best-effort: unsupported platforms (macOS/web) or init
  // failures must never block the app from launching.
  try {
    await MobileAds.instance.initialize();
    await AdConfig.configureRequestConfiguration();
  } catch (e) {
    AppLogger.w('MobileAds init skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: MobyAdsApp(),
    ),
  );
}

class MobyAdsApp extends ConsumerWidget {
  const MobyAdsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
