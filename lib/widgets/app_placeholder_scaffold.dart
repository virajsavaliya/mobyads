import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Reusable Placeholder Screen Scaffold for scaffolding navigation testing
class AppPlaceholderScaffold extends StatelessWidget {
  final String title;
  final String routeName;
  final IconData icon;
  final String description;
  final Widget? customContent;

  const AppPlaceholderScaffold({
    super.key,
    required this.title,
    required this.routeName,
    required this.icon,
    this.description = 'Scaffolded placeholder screen. Ready for feature implementation.',
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero card indicating current screen
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppSpacing.roundedL,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Text(
                        'Route: $routeName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              if (customContent != null) ...[
                const SizedBox(height: AppSpacing.l),
                customContent!,
              ],

              const SizedBox(height: AppSpacing.xl),
              Text(
                'Quick Route Navigation',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  _NavChip(label: 'Splash', route: '/splash', currentRoute: routeName),
                  _NavChip(label: 'Login', route: '/login', currentRoute: routeName),
                  _NavChip(label: 'Register', route: '/register', currentRoute: routeName),
                  _NavChip(label: 'Home', route: '/home', currentRoute: routeName),
                  _NavChip(label: 'Quiz', route: '/quiz', currentRoute: routeName),
                  _NavChip(label: 'Wallet', route: '/wallet', currentRoute: routeName),
                  _NavChip(label: 'Withdraw', route: '/withdraw', currentRoute: routeName),
                  _NavChip(label: 'Profile', route: '/profile', currentRoute: routeName),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final String label;
  final String route;
  final String currentRoute;

  const _NavChip({
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = route == currentRoute;

    return ActionChip(
      avatar: isCurrent
          ? const Icon(Icons.check_circle, size: 16, color: AppColors.accentDark)
          : const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
      label: Text(label),
      backgroundColor: isCurrent ? AppColors.accentLight : AppColors.surface,
      side: BorderSide(
        color: isCurrent ? AppColors.accent : AppColors.border,
      ),
      labelStyle: TextStyle(
        color: isCurrent ? AppColors.accentDark : AppColors.textPrimary,
        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
      ),
      onPressed: isCurrent ? null : () => context.push(route),
    );
  }
}
