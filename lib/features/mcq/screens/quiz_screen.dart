import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/config/ad_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_logger.dart';
import '../../ads/widgets/app_banner_ad.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_state.dart';
import 'quiz_complete_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  RewardedAd? _rewardedAd;
  bool _isLoadingRewardedAd = false;

  @override
  void initState() {
    super.initState();
    // Preload RewardedAd early at Q1 for Q5 milestone, and at Q6 for Q10 milestone
    _preloadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    super.dispose();
  }

  /// Preload RewardedAd in the background the moment the 5-question block starts
  /// (e.g. at Question 1 for Question 5, and at Question 6 for Question 10)
  void _preloadRewardedAd() {
    if (AdConfig.simulateAdFailure) {
      AppLogger.w('[Simulate Failure Mode] Skipping rewarded ad preload.');
      _rewardedAd = null;
      return;
    }
    if (_rewardedAd != null || _isLoadingRewardedAd) return;

    _isLoadingRewardedAd = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          AppLogger.d('AdMob RewardedAd preloaded successfully for milestone');
          if (!mounted) {
            ad.dispose();
            return;
          }
          _rewardedAd = ad;
          _isLoadingRewardedAd = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          AppLogger.w('AdMob RewardedAd failed to preload: ${error.message}');
          _rewardedAd = null;
          _isLoadingRewardedAd = false;
        },
      ),
    );
  }

  /// Explicit handler for RewardedAd failure (unavailable, network timeout, or show failure).
  ///
  /// Product Architecture:
  /// - Flags the session with [quizNotifier.flagRewardAdUnconfirmed] for backend audit.
  /// - Seamlessly allows the user to continue rather than getting locked in an error state.
  /// - Backend reward reconciliation determines whether to credit, partially credit, or review.
  void handleRewardedAdFailure({
    required int questionNumber,
    required String reason,
    required VoidCallback proceed,
    required QuizSessionController quizNotifier,
  }) {
    AppLogger.e(
      'RewardedAd Milestone Failure: Question #$questionNumber | Reason: $reason | '
      'Triggering server-side unconfirmed ad flag.',
    );

    quizNotifier.flagRewardAdUnconfirmed(
      questionNumber: questionNumber,
      reason: reason,
    );

    proceed();
  }

  /// Handles answer submission and question progression
  Future<void> _handleNextQuestion({
    required QuizState quizState,
    required QuizSessionController quizNotifier,
  }) async {
    if (!quizState.hasSelectedOption) return;

    final int questionNum = quizState.currentQuestionNumber;
    final bool isVideoMilestone = questionNum % 5 == 0;

    void proceedToNext() {
      quizNotifier.submitAnswerAndAdvance();
      // If we just finished a milestone block (e.g. Q5), preload the next RewardedAd block (for Q10)
      if (isVideoMilestone && questionNum < quizState.totalQuestions) {
        _preloadRewardedAd();
      }
    }

    // 1. Rewarded Video Ad Milestone (Question #5 and #10)
    if (isVideoMilestone) {
      if (_rewardedAd != null) {
        final adToShow = _rewardedAd!;
        _rewardedAd = null; // Clear cached reference immediately

        // SSV: opaque session as custom-data BEFORE show (PDF §11-12).
        final sessionId = await quizNotifier.beginRewardSession();
        try {
          await adToShow.setServerSideOptions(
            ServerSideVerificationOptions(customData: sessionId),
          );
        } catch (e) {
          AppLogger.w('SSV options attach failed, continuing: $e');
        }

        adToShow.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (RewardedAd ad) {
            AppLogger.i('RewardedAd dismissed for question #$questionNum');
            ad.dispose();
            proceedToNext();
          },
          onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
            ad.dispose();
            handleRewardedAdFailure(
              questionNumber: questionNum,
              reason: 'FailedToShow: ${error.message}',
              proceed: proceedToNext,
              quizNotifier: quizNotifier,
            );
          },
        );

        adToShow.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            AppLogger.i(
              'RewardedAd milestone verified: Q#$questionNum | Reward: ${reward.amount} ${reward.type}',
            );
            quizNotifier.recordRewardedAdConfirmed(
              questionNumber: questionNum,
              rewardAmount: reward.amount,
              rewardType: reward.type,
            );
          },
        );
      } else {
        // RewardedAd was not ready or failed to load
        handleRewardedAdFailure(
          questionNumber: questionNum,
          reason: 'AdNotReadyOrLoadFailed',
          proceed: proceedToNext,
          quizNotifier: quizNotifier,
        );
      }
      return;
    }

    // 2. Standard Questions (#1-4, #6-9): Go DIRECTLY to next question without interstitial interruption
    proceedToNext();
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            SizedBox(width: 8),
            Text('Leave Quiz?'),
          ],
        ),
        content: const Text(
          "Your progress and today's reward for this session will be lost.",
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 38),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'Leave Anyway',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final quizNotifier = ref.read(quizControllerProvider.notifier);

    // If quiz is completed
    if (quizState.step == QuizStep.completed) {
      return QuizCompleteScreen(
        earnedAmount: quizState.earnedAmount,
        totalCoins: quizState.totalCoinsEarned,
        totalQuestions: quizState.totalQuestions,
        confirmedMilestones:
            quizState.confirmedRewardMilestones.length,
        unconfirmedMilestones:
            quizState.unconfirmedRewardMilestones.length,
      );
    }

    // Hardened empty state: no questions delivered (backend empty/blocked)
    if (quizState.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Exit Quiz',
            onPressed: () async {
              final shouldLeave = await _showExitDialog(context);
              if (shouldLeave && context.mounted) {
                context.go('/home');
              }
            },
          ),
          title: const Text(
            'Quiz unavailable',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.quiz_outlined,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const Text(
                    'No questions right now',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Check back soon or try again.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  ElevatedButton.icon(
                    onPressed: () => quizNotifier.restartQuiz(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Quiz Question Step with PopScope Exit Protection
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _showExitDialog(context);
        if (shouldLeave && context.mounted) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Exit Quiz',
            onPressed: () async {
              final shouldLeave = await _showExitDialog(context);
              if (shouldLeave && context.mounted) {
                context.go('/home');
              }
            },
          ),
          title: Text(
            'Question ${quizState.currentQuestionNumber} of ${quizState.totalQuestions}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: quizState.progress,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable Question Content (distilled: question + options only)
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Freshness & Category Badge
                      _buildFreshnessBadge(
                        quizState.currentQuestion.category,
                        isMilestone: quizState.currentQuestionNumber % 5 == 0,
                      ),
                      const SizedBox(height: AppSpacing.s),

                      // Question Card
                      _buildQuestionCard(context, quizState),
                      const SizedBox(height: AppSpacing.l),

                      // 4 Options
                      ...List.generate(
                        quizState.currentQuestion.options.length,
                        (index) {
                          final optionText =
                              quizState.currentQuestion.options[index];
                          final isSelected =
                              quizState.selectedOptionIndex == index;
                          return _OptionCard(
                            index: index,
                            text: optionText,
                            isSelected: isSelected,
                            onTap: () => quizNotifier.selectOption(index),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.s),
                    ],
                  ),
                ),
              ),

              // 2. Action Button Bar ("Next Question" / "Watch Video & Continue" / "Submit & Finish")
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: const Border(
                    top: BorderSide(color: AppColors.divider, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: quizState.hasSelectedOption
                      ? () => _handleNextQuestion(
                            quizState: quizState,
                            quizNotifier: quizNotifier,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: quizState.hasSelectedOption
                        ? AppColors.primary
                        : AppColors.border,
                    foregroundColor: Colors.white,
                    minimumSize:
                        const Size(double.infinity, AppSpacing.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quizState.isLastQuestion
                            ? 'Submit & Finish'
                            : (quizState.currentQuestionNumber % 5 == 0
                                ? 'Watch Video & Continue'
                                : 'Next Question'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        quizState.currentQuestionNumber % 5 == 0
                            ? Icons.play_circle_fill_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. BOTTOM Persistent Banner Ad (single placement, above system nav)
              const ContainerBannerStrip(
                child: AppBannerAd(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Category / Freshness badge with Milestone indicator for Q5 & Q10
  Widget _buildFreshnessBadge(String category, {bool isMilestone = false}) {
    final isNational = category.toLowerCase().contains('national');
    final iconEmoji = isNational ? '🇮🇳' : '🌍';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(iconEmoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text(
                '$category · Today',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (isMilestone) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 13,
                  color: AppColors.accentDark,
                ),
                SizedBox(width: 4),
                Text(
                  'Milestone Reward',
                  style: TextStyle(
                    color: AppColors.accentDark,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Question Card Container
  Widget _buildQuestionCard(BuildContext context, QuizState state) {
    final question = state.currentQuestion;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (question.sourceName != null) ...[
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verified via ${question.sourceName}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Styled strip container for persistent top/bottom banner ads
class ContainerBannerStrip extends StatelessWidget {
  final Widget child;

  const ContainerBannerStrip({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// Option Button Widget
class _OptionCard extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  String get optionLetter {
    switch (index) {
      case 0:
        return 'A';
      case 1:
        return 'B';
      case 2:
        return 'C';
      case 3:
        return 'D';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s + 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2.0 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Option Letter Badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      optionLetter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),

                // Option Text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),

                // Radio Indicator
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color:
                      isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
