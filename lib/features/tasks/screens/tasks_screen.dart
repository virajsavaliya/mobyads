import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/task_model.dart';
import '../../../widgets/loading_button.dart';
import '../../ads/widgets/app_banner_ad.dart';
import '../../home/providers/home_dashboard_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _isClaimingDaily = false;
  bool _hasClaimedDaily = false;
  bool _isWatchingBonus = false;

  Future<void> _claimDailyBonus() async {
    setState(() => _isClaimingDaily = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isClaimingDaily = false;
        _hasClaimedDaily = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Daily reward claimed: +₹2.00 credited to wallet!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _watchBonusAd() async {
    setState(() => _isWatchingBonus = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _isWatchingBonus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Bonus Ad reward: +₹0.50 (50 Coins) credited!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeState = ref.watch(homeDashboardProvider);
    final currentTask = homeState.currentTask;
    final isAvailable = currentTask.status == TaskStatus.available;
    final isLocked = currentTask.status == TaskStatus.locked;
    final isInProgress = currentTask.status == TaskStatus.inProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Tasks & Rewards'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Summary Banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF27272A),
                      Color(0xFF18181B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF18181B).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.military_tech_rounded,
                        color: AppColors.accentGold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Earning Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Complete verified news quizzes & daily tasks to earn cash.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Section Title: Primary Tasks
              Text(
                'FEATURED TASKS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s),

              // 1. Featured Dynamic Continuous Task Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isLocked
                        ? AppColors.divider
                        : isAvailable
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.primary,
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
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
                            size: 24,
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
                                        ? 'Current Affairs Quiz'
                                        : 'Quiz In Progress',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLocked
                                    ? 'Unlocks in ${homeState.formattedRemainingTime}'
                                    : isAvailable
                                        ? '10 National & Global News Questions'
                                        : '10-MCQ session active • Resume quiz',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLocked
                                      ? const Color(0xFFD97706)
                                      : AppColors.textSecondary,
                                  fontWeight: isLocked ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isLocked ? AppColors.divider : AppColors.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+₹15.00',
                            style: TextStyle(
                              color: isLocked ? AppColors.textSecondary : AppColors.accentDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Dynamic action button
                    if (isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Unlocks in ${homeState.formattedRemainingTime}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF27272A),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      LoadingButton(
                        label: isInProgress
                            ? 'Continue 10-Question Quiz'
                            : 'Start 10-Question Quiz',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => context.push('/quiz'),
                        backgroundColor: AppColors.primary,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Section Title: Quick Daily Bonuses
              Text(
                'DAILY BONUSES & OFFERS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s),

              // 2. Daily Check-in Card
              _buildTaskCard(
                icon: Icons.calendar_today_rounded,
                iconColor: Colors.orange.shade700,
                title: 'Daily Streak Check-in',
                subtitle: _hasClaimedDaily
                    ? 'Claimed for today • Come back tomorrow'
                    : 'Check in every day to grow your bonus streak',
                reward: '+₹2.00',
                action: LoadingButton(
                  label: _hasClaimedDaily ? 'Claimed' : 'Claim +₹2.00',
                  icon: _hasClaimedDaily ? Icons.check : Icons.card_giftcard,
                  height: 38,
                  isLoading: _isClaimingDaily,
                  backgroundColor: AppColors.accentDark,
                  onPressed: _hasClaimedDaily ? null : _claimDailyBonus,
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // 3. Sponsored Video Bonus Card
              _buildTaskCard(
                icon: Icons.play_circle_fill_rounded,
                iconColor: AppColors.primary,
                title: 'Watch Sponsored Video',
                subtitle: 'Watch a 15-second sponsor spotlight',
                reward: '+₹0.50',
                action: LoadingButton(
                  label: 'Watch Video',
                  icon: Icons.ondemand_video_rounded,
                  height: 38,
                  isLoading: _isWatchingBonus,
                  isOutlined: true,
                  backgroundColor: AppColors.primary,
                  onPressed: _watchBonusAd,
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // 4. Friend Referral Bonus Card
              _buildTaskCard(
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF3F3F46),
                title: 'Refer & Earn ₹25',
                subtitle: 'Invite friends using your personal referral code',
                reward: '+₹25.00',
                action: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('Share Referral Link'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral link copied to clipboard! (MOBY2026)'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Sponsored Banner Ad
              const Center(
                child: AppBannerAd(),
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String reward,
    required Widget action,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  reward,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          action,
        ],
      ),
    );
  }
}
