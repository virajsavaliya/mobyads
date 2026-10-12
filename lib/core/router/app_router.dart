import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/mcq/screens/quiz_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/withdrawals/screens/withdraw_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/payout_methods_screen.dart';
import '../../features/profile/screens/notification_preferences_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/terms_conditions_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/about_screen.dart';
import '../../features/coupons/screens/coupons_screen.dart';
import '../../widgets/main_nav_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _walletNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'walletNav');
final _quizNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'quizNav');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

/// Provider for GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return appRouter;
});

/// Reusable page transition builder with subtle fade and slide
CustomTransitionPage<void> _buildPageWithTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

/// Application Router Definition
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Standalone Top-Level Routes (Outside Bottom Navigation)
    GoRoute(
      path: '/splash',
      name: 'splash',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: '/withdraw',
      name: 'withdraw',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const WithdrawScreen(),
      ),
    ),
    GoRoute(
      path: '/quiz',
      name: 'quiz',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const QuizScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/edit',
      name: 'profile_edit',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/payout-methods',
      name: 'profile_payout_methods',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const PayoutMethodsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/notifications',
      name: 'profile_notifications',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const NotificationPreferencesScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/privacy-policy',
      name: 'profile_privacy_policy',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const PrivacyPolicyScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/terms',
      name: 'profile_terms',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const TermsConditionsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/help',
      name: 'profile_help',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const HelpSupportScreen(),
      ),
    ),
    GoRoute(
      path: '/coupons',
      name: 'coupons',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const CouponsScreen(),
      ),
    ),
    GoRoute(
      path: '/profile/about',
      name: 'profile_about',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => _buildPageWithTransition(
        context: context,
        state: state,
        child: const AboutScreen(),
      ),
    ),

    // Persistent Bottom Navigation Shell (StatefulShellRoute)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Tab 1: Wallet
        StatefulShellBranch(
          navigatorKey: _walletNavigatorKey,
          routes: [
            GoRoute(
              path: '/wallet',
              name: 'wallet',
              builder: (context, state) => const WalletScreen(),
            ),
          ],
        ),

        // Tab 2: Tasks & Offers
        StatefulShellBranch(
          navigatorKey: _quizNavigatorKey,
          routes: [
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              builder: (context, state) => const TasksScreen(),
            ),
          ],
        ),

        // Tab 3: Profile
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page Not Found: ${state.uri.toString()}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    ),
  ),
);
