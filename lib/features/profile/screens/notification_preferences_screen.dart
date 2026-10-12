import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/notification_preferences_controller.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  void _showUpdateToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
                child: Text(
                  'PUSH NOTIFICATION PREFERENCES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
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
                  children: [
                    // 1. Task Reminders
                    _buildSwitchTile(
                      context,
                      title: 'Task Reminders',
                      subtitle: 'Get alerted when new daily news quizzes are ready to play',
                      icon: Icons.alarm_rounded,
                      iconColor: AppColors.primary,
                      value: prefs.taskReminders,
                      onChanged: (val) {
                        notifier.toggleTaskReminders(val);
                        _showUpdateToast(context, 'Task reminders ${val ? "enabled" : "disabled"}');
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.divider),

                    // 2. Reward Credited
                    _buildSwitchTile(
                      context,
                      title: 'Reward Credited',
                      subtitle: 'Instant alerts whenever coins and cash rewards are added to wallet',
                      icon: Icons.monetization_on_outlined,
                      iconColor: AppColors.accentDark,
                      value: prefs.rewardCredited,
                      onChanged: (val) {
                        notifier.toggleRewardCredited(val);
                        _showUpdateToast(context, 'Reward alerts ${val ? "enabled" : "disabled"}');
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.divider),

                    // 3. Withdrawal Updates
                    _buildSwitchTile(
                      context,
                      title: 'Withdrawal Updates',
                      subtitle: 'Status alerts when your bank payouts are approved and transferred',
                      icon: Icons.account_balance_outlined,
                      iconColor: Colors.blue.shade700,
                      value: prefs.withdrawalUpdates,
                      onChanged: (val) {
                        notifier.toggleWithdrawalUpdates(val);
                        _showUpdateToast(context, 'Withdrawal alerts ${val ? "enabled" : "disabled"}');
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.divider),

                    // 4. Coupons & Offers
                    _buildSwitchTile(
                      context,
                      title: 'Coupon & Offers',
                      subtitle: 'Special earning promotions, booster events, and sponsor bonuses',
                      icon: Icons.local_offer_outlined,
                      iconColor: Colors.purple.shade600,
                      value: prefs.couponsAndOffers,
                      onChanged: (val) {
                        notifier.toggleCouponsAndOffers(val);
                        _showUpdateToast(context, 'Offers & coupons ${val ? "enabled" : "disabled"}');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.l),

              // Info card
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You can adjust system-level notification permissions anytime in your device Settings.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
