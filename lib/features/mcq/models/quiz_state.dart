import 'question_model.dart';

enum QuizStep {
  question,
  ad,
  completed,
}

/// State representation for Quiz flow
class QuizState {
  final QuizStep step;
  final List<Question> questions;
  final int currentIndex;
  final int? selectedOptionIndex;
  final Map<int, int> userAnswers;
  final double earnedAmount;
  final int totalCoinsEarned;
  final String? activeRewardSessionId;

  final List<int> skippedAdQuestions;
  final List<int> confirmedRewardMilestones;
  final List<int> unconfirmedRewardMilestones;

  const QuizState({
    this.step = QuizStep.question,
    required this.questions,
    this.currentIndex = 0,
    this.selectedOptionIndex,
    this.userAnswers = const {},
    this.earnedAmount = 0.0,
    this.totalCoinsEarned = 0,
    this.activeRewardSessionId,
    this.skippedAdQuestions = const [],
    this.confirmedRewardMilestones = const [],
    this.unconfirmedRewardMilestones = const [],
  });

  Question get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : mockDailyQuizQuestions.first;

  int get totalQuestions => questions.length;
  int get currentQuestionNumber => currentIndex + 1;
  bool get hasSelectedOption => selectedOptionIndex != null;
  bool get isLastQuestion => currentIndex == questions.length - 1;

  double get progress => totalQuestions > 0
      ? ((currentIndex + (step == QuizStep.ad ? 1 : 0)) / totalQuestions)
          .clamp(0.0, 1.0)
      : 0.0;

  QuizState copyWith({
    QuizStep? step,
    List<Question>? questions,
    int? currentIndex,
    int? selectedOptionIndex,
    bool clearSelectedOption = false,
    Map<int, int>? userAnswers,
    double? earnedAmount,
    int? totalCoinsEarned,
    String? activeRewardSessionId,
    bool clearRewardSession = false,
    List<int>? skippedAdQuestions,
    List<int>? confirmedRewardMilestones,
    List<int>? unconfirmedRewardMilestones,
  }) {
    return QuizState(
      step: step ?? this.step,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOptionIndex: clearSelectedOption
          ? null
          : (selectedOptionIndex ?? this.selectedOptionIndex),
      userAnswers: userAnswers ?? this.userAnswers,
      earnedAmount: earnedAmount ?? this.earnedAmount,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      activeRewardSessionId: clearRewardSession
          ? null
          : (activeRewardSessionId ?? this.activeRewardSessionId),
      skippedAdQuestions: skippedAdQuestions ?? this.skippedAdQuestions,
      confirmedRewardMilestones:
          confirmedRewardMilestones ?? this.confirmedRewardMilestones,
      unconfirmedRewardMilestones:
          unconfirmedRewardMilestones ?? this.unconfirmedRewardMilestones,
    );
  }
}
