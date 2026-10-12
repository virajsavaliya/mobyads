import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../../ads/services/reward_session_service.dart';
import '../../home/providers/home_dashboard_provider.dart';
import '../models/question_model.dart';
import '../models/quiz_state.dart';
import '../services/quiz_submission_service.dart';

final quizSubmissionServiceProvider = Provider<QuizSubmissionService>((ref) {
  return QuizSubmissionService(ApiClient());
});

final rewardSessionServiceProvider = Provider<RewardSessionService>((ref) {
  return RewardSessionService(ApiClient());
});

final quizControllerProvider =
    StateNotifierProvider.autoDispose<QuizSessionController, QuizState>((ref) {
  final homeDashboardNotifier = ref.read(homeDashboardProvider.notifier);

  return QuizSessionController(
    homeDashboardNotifier,
    submissionService: ref.read(quizSubmissionServiceProvider),
    rewardSessionService: ref.read(rewardSessionServiceProvider),
    initialQuestions: mockDailyQuizQuestions.take(10).toList(),
  );
});

/// State notifier managing the sequence:
/// Question -> Interstitial/Video Ad -> Question -> ... -> Completed
class QuizSessionController extends StateNotifier<QuizState> {
  final HomeDashboardNotifier _homeDashboardNotifier;
  final QuizSubmissionService _submissionService;
  final RewardSessionService _rewardSessionService;
  final List<Question> _pool;

  static const double rewardPerQuestion = 1.50; // fallback when offline
  static const int coinsPerQuestion = 150;

  QuizSessionController(
    this._homeDashboardNotifier, {
    required List<Question> initialQuestions,
    QuizSubmissionService? submissionService,
    RewardSessionService? rewardSessionService,
  })  : _pool = initialQuestions,
        _submissionService =
            submissionService ?? QuizSubmissionService(ApiClient()),
        _rewardSessionService =
            rewardSessionService ?? RewardSessionService(ApiClient()),
        super(QuizState(questions: List.from(initialQuestions))) {
    Future.microtask(() => _homeDashboardNotifier.startTask());
  }

  /// Creates an opaque SSV session BEFORE showing a rewarded ad (PDF §11-12).
  /// Caller attaches [sessionId] as AdMob custom-data; client never credits from it.
  Future<String> beginRewardSession({String taskType = 'REWARDED_AD'}) async {
    final result = await _rewardSessionService.create(taskType: taskType);
    state = state.copyWith(activeRewardSessionId: result.sessionId);
    if (result.isFallback) {
      AppLogger.w('Reward session offline fallback: ${result.sessionId}');
    }
    return result.sessionId;
  }

  /// Selects an option for the current question
  void selectOption(int optionIndex) {
    if (state.step != QuizStep.question) return;
    state = state.copyWith(selectedOptionIndex: optionIndex);
  }

  /// Submits the current question's answer and gates with an ad step
  void submitCurrentAnswer() {
    if (state.selectedOptionIndex == null || state.step != QuizStep.question) {
      return;
    }

    final updatedAnswers = Map<int, int>.from(state.userAnswers);
    updatedAnswers[state.currentIndex] = state.selectedOptionIndex!;

    final nextEarned = state.earnedAmount + rewardPerQuestion;
    final nextCoins = state.totalCoinsEarned + coinsPerQuestion;

    state = state.copyWith(
      userAnswers: updatedAnswers,
      earnedAmount: nextEarned,
      totalCoinsEarned: nextCoins,
      step: QuizStep.ad,
    );
  }

  /// Records current answer and directly advances to the next question
  /// (used when interstitial ad is shown or skipped without extra ad step screen).
  void submitAnswerAndAdvance() {
    if (state.selectedOptionIndex == null || state.step != QuizStep.question) {
      return;
    }

    final updatedAnswers = Map<int, int>.from(state.userAnswers);
    updatedAnswers[state.currentIndex] = state.selectedOptionIndex!;

    final nextEarned = state.earnedAmount + rewardPerQuestion;
    final nextCoins = state.totalCoinsEarned + coinsPerQuestion;

    if (state.isLastQuestion) {
      _homeDashboardNotifier.recordQuizCompleted(
        rewardAmount: nextEarned,
      );
      state = state.copyWith(
        userAnswers: updatedAnswers,
        earnedAmount: nextEarned,
        totalCoinsEarned: nextCoins,
        step: QuizStep.completed,
      );
    } else {
      state = state.copyWith(
        userAnswers: updatedAnswers,
        earnedAmount: nextEarned,
        totalCoinsEarned: nextCoins,
        currentIndex: state.currentIndex + 1,
        clearSelectedOption: true,
        step: QuizStep.question,
      );
    }
  }

  /// Server-validated advance (PDF §7): reports answer, server decides reward.
  /// Idempotency key is stable per question index so retries cannot double-pay.
  /// Falls back to local credit when backend is unreachable (M2-M3 transition).
  Future<QuizSubmitResult?> submitAnswerViaServer() async {
    if (state.selectedOptionIndex == null || state.step != QuizStep.question) {
      return null;
    }
    final index = state.currentIndex;
    final question = state.currentQuestion;
    final selected = state.selectedOptionIndex!;
    final key = 'quiz-${question.id}-$index';

    QuizSubmitResult? result;
    bool usedFallback = false;
    try {
      result = await _submissionService.submit(
        questionId: question.id,
        selectedIndex: selected,
        idempotencyKey: key,
      );
    } on DioException catch (e) {
      AppLogger.w('Quiz submit offline, local fallback: $e');
      usedFallback = true;
    }

    final updatedAnswers = Map<int, int>.from(state.userAnswers);
    updatedAnswers[index] = selected;

    double credit = 0;
    int coins = 0;
    if (result != null && result.isCorrect) {
      credit = result.rewardAmount > 0 ? result.rewardAmount : rewardPerQuestion;
      coins = (credit * 100).round();
    } else if (usedFallback) {
      // Offline transition: preserve old UX until backend live.
      credit = rewardPerQuestion;
      coins = coinsPerQuestion;
    }

    final nextEarned = state.earnedAmount + credit;
    final nextCoins = state.totalCoinsEarned + coins;

    if (state.isLastQuestion) {
      _homeDashboardNotifier.recordQuizCompleted(rewardAmount: nextEarned);
      state = state.copyWith(
        userAnswers: updatedAnswers,
        earnedAmount: nextEarned,
        totalCoinsEarned: nextCoins,
        step: QuizStep.completed,
      );
    } else {
      state = state.copyWith(
        userAnswers: updatedAnswers,
        earnedAmount: nextEarned,
        totalCoinsEarned: nextCoins,
        currentIndex: index + 1,
        clearSelectedOption: true,
        step: QuizStep.question,
      );
    }
    return result;
  }

  /// Flags a question where an interstitial ad was not shown (failed or not ready).
  /// Logs and records the session event for server-side verification and backend reward logic.
  void flagAdNotShown({required int questionNumber, required String reason}) {
    AppLogger.w(
      'Ad Impression Flagged [Not Shown]: Question #$questionNumber | Reason: $reason | '
      'Session progress: ${state.currentIndex + 1}/${state.totalQuestions}',
    );
    final updatedList = List<int>.from(state.skippedAdQuestions);
    if (!updatedList.contains(questionNumber)) {
      updatedList.add(questionNumber);
    }
    state = state.copyWith(skippedAdQuestions: updatedList);
  }

  /// Records a confirmed RewardedAd completion triggered via onUserEarnedReward.
  /// Notifies the backend reward session verification logic.
  void recordRewardedAdConfirmed({
    required int questionNumber,
    required num rewardAmount,
    required String rewardType,
  }) {
    AppLogger.i(
      'Rewarded Ad Verified: Question #$questionNumber | Earned: $rewardAmount $rewardType | '
      'Session progress: ${state.currentIndex + 1}/${state.totalQuestions}',
    );
    final updatedList = List<int>.from(state.confirmedRewardMilestones);
    if (!updatedList.contains(questionNumber)) {
      updatedList.add(questionNumber);
    }
    state = state.copyWith(confirmedRewardMilestones: updatedList);
  }

  /// Flags a milestone where a RewardedAd failed to load/show.
  /// Records the session event so backend reward verification can decide whether to hold or credit.
  void flagRewardAdUnconfirmed({
    required int questionNumber,
    required String reason,
  }) {
    AppLogger.e(
      'Rewarded Ad Unconfirmed: Question #$questionNumber | Reason: $reason | '
      'Session flagged for backend reward audit.',
    );
    final updatedList = List<int>.from(state.unconfirmedRewardMilestones);
    if (!updatedList.contains(questionNumber)) {
      updatedList.add(questionNumber);
    }
    state = state.copyWith(unconfirmedRewardMilestones: updatedList);
  }

  /// Called when the ad (video milestone or manual gate) completes
  void onAdFinished() {
    if (state.step != QuizStep.ad) return;

    if (state.isLastQuestion) {
      // Completed all 10 questions and final ad!
      _homeDashboardNotifier.recordQuizCompleted(
        rewardAmount: state.earnedAmount,
      );

      state = state.copyWith(
        step: QuizStep.completed,
      );
    } else {
      // Proceed to the next question
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearSelectedOption: true,
        step: QuizStep.question,
      );
    }
  }

  /// Restarts the quiz session
  void restartQuiz() {
    _homeDashboardNotifier.startTask();
    state = QuizState(questions: List.from(_pool));
  }
}
