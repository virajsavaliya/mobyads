import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Onboarding (Persuade): one idea per slide — Answer, Watch, Withdraw.
/// Shown once on first run; Skip / Get started persist the flag.
class OnboardingScreen extends StatefulWidget {
  /// Test seam: called instead of router navigation on finish.
  final VoidCallback? onFinish;

  const OnboardingScreen({super.key, this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  const _Slide(this.icon, this.title, this.body);
}

const _slides = [
  _Slide(
    Icons.quiz_rounded,
    'Answer daily quizzes',
    'Ten quick questions from verified news. Correct answers earn real rewards.',
  ),
  _Slide(
    Icons.play_circle_fill_rounded,
    'Watch sponsor ads',
    'Short videos at milestones add bonus earnings to the same wallet.',
  ),
  _Slide(
    Icons.account_balance_wallet_rounded,
    'Withdraw real money',
    'Cash out to bank or Paytm once you reach the minimum. No games, just payouts.',
  ),
];

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
    if (!mounted) return;
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else {
      context.go('/login');
    }
  }

  Future<void> _nextOrFinish() async {
    if (_index < _slides.length - 1) {
      await _pages.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    await _finish();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            s.icon,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _index == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Padding(
              padding: AppSpacing.screenPadding,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextOrFinish,
                  child: Text(
                    _index == _slides.length - 1
                        ? 'Get started'
                        : 'Next',
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }
}
