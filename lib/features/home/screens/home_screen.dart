import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/config/ad_config.dart';
import '../../../core/config/server_config_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/task_model.dart';
import '../../ads/widgets/app_banner_ad.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/home_dashboard_state.dart';
import '../providers/home_dashboard_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _adCarouselController;
  late final List<BannerAd?> _carouselAds;
  Timer? _adCarouselTimer;
  int _currentAdSlide = 0;

  static const int _slideCount = AdConfig.adCarouselSlideCount;

  @override
  void initState() {
    super.initState();
    _carouselAds = List<BannerAd?>.filled(_slideCount, null, growable: false);
    _initIndependentCarouselAds();
    _adCarouselController = PageController();
    _startAdCarouselTimer();
    Future.microtask(
      () => ref.read(serverConfigProvider.notifier).load(),
    );
  }

  /// Creates and loads a separate, independent BannerAd instance per slide
  void _initIndependentCarouselAds() {
    for (int i = 0; i < _slideCount; i++) {
      final bannerAd = BannerAd(
        adUnitId: AdConfig.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            final timestamp = DateTime.now().toIso8601String();
            AppLogger.d(
              '[AdCarousel Slide $i] Independent BannerAd loaded at $timestamp (Unit: ${ad.adUnitId})',
            );
            if (mounted) {
              setState(() {
                _carouselAds[i] = ad as BannerAd;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            AppLogger.w(
              '[AdCarousel Slide $i] Independent BannerAd failed to load: ${error.message}',
            );
            ad.dispose();
            if (mounted) {
              setState(() {
                _carouselAds[i] = null;
              });
            }
          },
        ),
      );

      bannerAd.load();
    }
  }

  void _startAdCarouselTimer() {
    _adCarouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_adCarouselController.hasClients) {
        final nextPage = (_currentAdSlide + 1) % _slideCount;
        _adCarouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _adCarouselTimer?.cancel();
    _adCarouselController.dispose();
    // Dispose ALL independent BannerAd instances to prevent memory leaks
    for (int i = 0; i < _carouselAds.length; i++) {
      _carouselAds[i]?.dispose();
      _carouselAds[i] = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final dashboardState = ref.watch(homeDashboardProvider);
    final serverConfig = ref.watch(serverConfigProvider);
    final userName = authState.user?.name ?? 'Earner';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeDashboardProvider.notifier).refresh(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Custom App Bar Area
                _buildHeader(context, theme, userName),
                const SizedBox(height: AppSpacing.m),

                // 2. Sponsored Ad Slider (top of page, fading slides)
                _buildAdCarousel(context, theme),
                const SizedBox(height: AppSpacing.m),

                // 3. Balance hero: Available largest, Pending secondary, Withdraw CTA
                _buildBalanceHero(context, theme, dashboardState),
                const SizedBox(height: AppSpacing.m),

                // 4. "Today's Task" Section (single next-task CTA)
                _buildTodayTaskSection(
                  context,
                  theme,
                  dashboardState,
                  serverRewardTotal: serverConfig.rewardMcq *
                      serverConfig.mcqCount,
                  dailyLimit: serverConfig.dailyLimit,
                ),
                const SizedBox(height: AppSpacing.l),

                // 5. Quick Stats Row (Total Earned / Tasks Today / Ads Watched)
                _buildQuickStatsRow(theme, dashboardState),
                const SizedBox(height: AppSpacing.l),

                // 6. Persistent Banner Ad (pinned placement above bottom nav)
                const Center(
                  child: AppBannerAd(),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Top Custom Header: Avatar + Greeting + Notification Bell
  Widget _buildHeader(BuildContext context, ThemeData theme, String userName) {
    return Row(
      children: [
        // Tappable Profile Avatar (48px min touch target, labeled)
        Semantics(
          button: true,
          label: 'Open profile',
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 48,
              height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Greeting Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $userName 👋',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Ready to earn today?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Notification Bell Icon (48px min touch target)
        SizedBox(
          width: 48,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
              tooltip: 'Notifications',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No new notifications right now.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 2b. Balance hero (distilled Home): Available largest with tabular
  /// figures, Pending secondary, Withdraw always visible.
  Widget _buildBalanceHero(
    BuildContext context,
    ThemeData theme,
    HomeDashboardState dashboardState,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF18181B), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18181B).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AVAILABLE BALANCE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(dashboardState.availableBalance),
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pending ${Formatters.formatCurrency(dashboardState.pendingBalance)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/withdraw'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_circle_up_rounded, size: 20),
              label: const Text(
                'Withdraw',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Auto-Scrolling Sponsored Ad Carousel Card
  Widget _buildAdCarousel(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: _adCarouselController,
              itemCount: _slideCount,
              onPageChanged: (index) {
                setState(() {
                  _currentAdSlide = index;
                });
              },
              itemBuilder: (context, index) {
                // Overlap fading: slides fade in/out with page offset
                // instead of showing hard sliding borders.
                final slide = AnimatedBuilder(
                  animation: _adCarouselController,
                  builder: (context, _) {
                    double offset = 0;
                    try {
                      offset = _adCarouselController.page ?? index.toDouble();
                    } catch (_) {
                      offset = index.toDouble();
                    }
                    final fade =
                        (1.0 - (offset - index).abs()).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: 0.35 + 0.65 * fade,
                      child: _buildSlide(context, index),
                    );
                  },
                );
                return slide;
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Dot Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slideCount,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentAdSlide == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentAdSlide == index
                    ? AppColors.primary
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Resolves the live or placeholder slide for a carousel index
  Widget _buildSlide(BuildContext context, int index) {
    final bannerAd = _carouselAds[index];
    if (bannerAd != null) {
      return _buildAdMobSlide(
        index: index,
        bannerAd: bannerAd,
      );
    }
    return _buildNeutralPlaceholderSlide(index: index);
  }
  Widget _buildAdMobSlide({
    required int index,
    required BannerAd bannerAd,
  }) {
    final List<List<Color>> gradients = [
      const [Color(0xFF09090B), Color(0xFF27272A)],
      const [Color(0xFF18181B), Color(0xFF000000)],
      const [Color(0xFF3F3F46), Color(0xFF18181B)],
      const [Color(0xFF52525B), Color(0xFF27272A)],
    ];
    final gradient = gradients[index % gradients.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SPONSOR #${index + 1}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.verified_outlined, color: Colors.white70, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Ad Slot ${index + 1}/$_slideCount',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: bannerAd.size.width.toDouble(),
                height: bannerAd.size.height.toDouble(),
                child: AdWidget(ad: bannerAd),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Neutral Placeholder Slide shown when a specific ad slot is loading or failed
  Widget _buildNeutralPlaceholderSlide({required int index}) {
    final List<Map<String, dynamic>> fallbackOffers = [
      {
        'title': 'Featured Partner Deals',
        'subtitle': 'Complete daily news quizzes to unlock sponsored brand rewards.',
        'gradient': [const Color(0xFF18181B), const Color(0xFF000000)],
        'icon': Icons.local_offer_rounded,
        'badge': 'FEATURED',
      },
      {
        'title': 'Daily Cashback Rewards',
        'subtitle': 'Sponsored by certified brand partners with guaranteed bank payouts.',
        'gradient': [const Color(0xFF27272A), const Color(0xFF3F3F46)],
        'icon': Icons.savings_rounded,
        'badge': 'SPONSOR',
      },
      {
        'title': 'Quiz Bonus Multiplier',
        'subtitle': 'Earn up to 2x bonus reward coins by maintaining your daily streak.',
        'gradient': [const Color(0xFF52525B), const Color(0xFF27272A)],
        'icon': Icons.stars_rounded,
        'badge': 'BOOST',
      },
      {
        'title': 'Verified News Sponsor',
        'subtitle': 'Daily educational affairs verified and supported by certified advertisers.',
        'gradient': [const Color(0xFF27272A), const Color(0xFF18181B)],
        'icon': Icons.verified_user_rounded,
        'badge': 'VERIFIED',
      },
    ];

    final offer = fallbackOffers[index % fallbackOffers.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: offer['gradient'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(offer['icon'] as IconData, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${offer['badge']} #${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Learn More',
                  style: TextStyle(
                    color: Color(0xFF09090B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer['title'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                offer['subtitle'] as String,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Quick stats row below the carousel (3 small stat chips)
  Widget _buildQuickStatsRow(ThemeData theme, dynamic dashboardState) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.savings_outlined,
            iconColor: AppColors.accentDark,
            bgColor: AppColors.accentLight,
            title: 'Total Earned',
            value: Formatters.formatCurrency(dashboardState.totalEarned),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _StatChip(
            icon: Icons.task_alt_rounded,
            iconColor: AppColors.primary,
            bgColor: AppColors.primaryLight,
            title: 'Tasks Today',
            value: '${dashboardState.tasksCompletedToday} done',
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _StatChip(
            icon: Icons.play_circle_outline_rounded,
            iconColor: const Color(0xFF52525B), // Gray
            bgColor: const Color(0xFFF4F4F5),
            title: 'Ads Watched',
            value: '${dashboardState.adsWatchedToday}',
          ),
        ),
      ],
    );
  }

  /// 4. "Today's Task" Section with continuous 24/7 dynamic state (Available / Locked with live countdown / In Progress)
  Widget _buildTodayTaskSection(
    BuildContext context,
    ThemeData theme,
    HomeDashboardState dashboardState, {
    required double serverRewardTotal,
    required double dailyLimit,
  }) {
    final task = dashboardState.currentTask;
    final isAvailable = task.status == TaskStatus.available;
    final isLocked = task.status == TaskStatus.locked;
    final isInProgress = task.status == TaskStatus.inProgress;

    // Header badge attributes
    final String badgeText;
    final Color badgeBg;
    final Color badgeTextColor;

    if (isAvailable) {
      badgeText = 'Ready';
      badgeBg = AppColors.accentLight;
      badgeTextColor = AppColors.accentDark;
    } else if (isLocked) {
      badgeText = 'Cooldown';
      badgeBg = const Color(0xFFFEF3C7); // Amber-100
      badgeTextColor = const Color(0xFFB45309); // Amber-700
    } else {
      badgeText = 'In Progress';
      badgeBg = AppColors.primaryLight;
      badgeTextColor = AppColors.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Task",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),

        // Prominent Dynamic Task Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked
                  ? AppColors.divider
                  : isAvailable
                      ? AppColors.primary.withValues(alpha: 0.22)
                      : AppColors.primary,
              width: isInProgress ? 1.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Status Icon + Title + Subtitle
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? const Color(0xFFF1F5F9)
                          : isAvailable
                              ? AppColors.accentLight
                              : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isLocked
                          ? Icons.lock_clock_rounded
                          : isAvailable
                              ? Icons.quiz_rounded
                              : Icons.play_circle_filled_rounded,
                      color: isLocked
                          ? AppColors.textSecondary
                          : isAvailable
                              ? AppColors.accentDark
                              : AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLocked
                              ? 'Next Task Locked'
                              : isAvailable
                                  ? 'Task Ready'
                                  : 'Task In Progress',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLocked
                              ? 'Next task unlocks in'
                              : isAvailable
                                  ? 'Earn up to ${Formatters.formatCurrency(serverRewardTotal)}'
                                  : '10-MCQ session active • Resume quiz',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isLocked
                                ? AppColors.textMuted
                                : isAvailable
                                    ? AppColors.accentDark
                                    : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              // Dynamic Middle Section & Action Button
              if (isLocked) ...[
                // Locked state: Live Countdown display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s + 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dashboardState.formattedRemainingTime,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          fontFeatures: [FontFeature.tabularFigures()],
                          color: Color(0xFF27272A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                const Center(
                  child: Text(
                    'Unlocks automatically when countdown reaches zero',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ] else if (isInProgress) ...[
                // In Progress State: Continue Task Button
                ElevatedButton.icon(
                  onPressed: () => context.push('/quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text(
                    'Continue Task',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else ...[
                // Available State: Start Task Button
                ElevatedButton.icon(
                  onPressed: () => context.push('/quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text(
                    'Start Task',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Center(
          child: Text(
            'Daily limit ${Formatters.formatCurrency(dailyLimit)} • server-configured rewards',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper Widget for the 3 Quick Stat Chips
class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String value;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
