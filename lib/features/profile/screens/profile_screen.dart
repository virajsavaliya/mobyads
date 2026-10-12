import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('Log Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your MobyAds account?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(90, 38),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 38),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }





  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final userName = user?.name ?? 'Alex Johnson';
    final userEmail = user?.email ?? 'alex.johnson@example.com';
    final bool isVerified = user != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Column(
            children: [
              // 1. Top User Profile Card with Avatar & Verification Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Large Circular Avatar with Camera/Edit Badge
                    GestureDetector(
                      onTap: () => context.push('/profile/edit'),
                      child: Stack(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accentDark,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // User Name
                    Text(
                      userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Email Address
                    Text(
                      userEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Verified Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? AppColors.accentLight
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isVerified
                              ? AppColors.accent
                              : Colors.orange.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified
                                ? Icons.verified_rounded
                                : Icons.pending_rounded,
                            size: 14,
                            color: isVerified
                                ? AppColors.accentDark
                                : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVerified ? 'Verified Account' : 'Unverified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isVerified
                                  ? AppColors.accentDark
                                  : Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // 2. Menu Group: Account & Financials
              _buildMenuSection(
                context,
                title: 'ACCOUNT & EARNINGS',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    title: 'Edit Profile',
                    subtitle: 'Name, phone & region settings',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_outlined,
                    iconColor: AppColors.accentDark,
                    title: 'Payout Methods',
                    subtitle: 'Bank accounts & payout history',
                    onTap: () => context.push('/profile/payout-methods'),
                  ),
                  _MenuItem(
                    icon: Icons.local_offer_outlined,
                    iconColor: Colors.orange.shade700,
                    title: 'My Coupons',
                    subtitle: 'Available, used & expired rewards',
                    onTap: () => context.push('/coupons'),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    iconColor: Colors.purple.shade600,
                    title: 'Notification Preferences',
                    subtitle: 'Quiz alerts, payouts & bonus updates',
                    onTap: () => context.push('/profile/notifications'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              // 3. Menu Group: Legal, Support & Info
              _buildMenuSection(
                context,
                title: 'LEGAL & SUPPORT',
                items: [
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.blueGrey.shade600,
                    title: 'Privacy Policy',
                    subtitle: 'Data collection & telemetry policies',
                    onTap: () => context.push('/profile/privacy-policy'),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    iconColor: Colors.blueGrey.shade600,
                    title: 'Terms & Conditions',
                    subtitle: 'Earning rules & fraud guidelines',
                    onTap: () => context.push('/profile/terms'),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    iconColor: Colors.amber.shade800,
                    title: 'Help & Support',
                    subtitle: 'FAQ, payout guides & support chat',
                    onTap: () => context.push('/profile/help'),
                  ),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.primary,
                    title: 'About MobyAds',
                    subtitle: 'Version, links & ecosystem info',
                    onTap: () => context.push('/profile/about'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),

              // 4. Logout Tile
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: 2,
                    ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: const Text(
                    'Safely exit your current session',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.error,
                  ),
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),

              // 5. App Version Footer
              Text(
                '${AppConstants.appName} v${AppConstants.appVersion} (Build 1)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Made with Flutter • Secure & Encrypted',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 54,
                color: AppColors.divider,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: 2,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 20, color: item.iconColor),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : null,
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                onTap: item.onTap,
              );
            },
          ),
        ),
      ),
    ],
  );
}
}

class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
