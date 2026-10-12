import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchExternalUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $urlString...')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $urlString...')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About MobyAds'),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.m),

              // 1. App Icon Logo Centerpiece
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // App Name
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),

              // Version Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'v${AppConstants.appVersion} (Build 1)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Description Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Text(
                  'MobyAds is a rewarding educational ecosystem that turns your daily current affairs knowledge into real cash earnings. By completing daily verified news quizzes and engaging with sponsor messages, learners sharpen their knowledge while earning guaranteed bank payouts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Action Tiles
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                        title: const Text('Official Website', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('https://mobyads.com'),
                        trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textMuted),
                        onTap: () => _launchExternalUrl(context, 'https://mobyads.com'),
                      ),
                      const Divider(height: 1, indent: 56, color: AppColors.divider),
                      ListTile(
                        leading: const Icon(Icons.star_rate_rounded, color: Colors.amber),
                        title: const Text('Rate MobyAds', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Love the app? Leave us a review'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Redirecting to App Store...')),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56, color: AppColors.divider),
                      ListTile(
                        leading: const Icon(Icons.share_rounded, color: AppColors.accentDark),
                        title: const Text('Share with Friends', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Invite others to earn together'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Referral link copied to clipboard!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Social Icons Row
              const Text(
                'CONNECT WITH US',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    context,
                    icon: Icons.alternate_email_rounded,
                    label: 'X / Twitter',
                    url: 'https://twitter.com',
                  ),
                  const SizedBox(width: AppSpacing.m),
                  _buildSocialButton(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: 'Instagram',
                    url: 'https://instagram.com',
                  ),
                  const SizedBox(width: AppSpacing.m),
                  _buildSocialButton(
                    context,
                    icon: Icons.play_circle_outline_rounded,
                    label: 'YouTube',
                    url: 'https://youtube.com',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Copyright Footer
              const Text(
                '© 2026 MobyAds Inc. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchExternalUrl(context, url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
