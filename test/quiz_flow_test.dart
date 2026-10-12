import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/mcq/controllers/quiz_controller.dart';
import 'package:mobyads/features/mcq/models/quiz_state.dart';

void main() {
  group('Quiz Flow & Ad Sequencing State Machine', () {
    test('Quiz starts on Question 1 of 10 with no selected option', () {
      final container = ProviderContainer();
      final quizState = container.read(quizControllerProvider);

      expect(quizState.currentIndex, 0);
      expect(quizState.currentQuestionNumber, 1);
      expect(quizState.selectedOptionIndex, isNull);
      expect(quizState.totalQuestions, 10);
      expect(quizState.step, QuizStep.question);
    });

    test('Option selection updates state without advancing prematurely', () {
      final container = ProviderContainer();
      final controller = container.read(quizControllerProvider.notifier);

      controller.selectOption(2);
      expect(container.read(quizControllerProvider).selectedOptionIndex, 2);

      // Change selection
      controller.selectOption(3);
      expect(container.read(quizControllerProvider).selectedOptionIndex, 3);
    });

    test('Ad sequencing boundaries: Question 5 & 10 are video ad milestones', () {
      final container = ProviderContainer();
      final controller = container.read(quizControllerProvider.notifier);

      // Question 1 -> Interstitial / Ad gate
      controller.selectOption(0);
      controller.submitCurrentAnswer();
      expect(container.read(quizControllerProvider).step, QuizStep.ad);
      expect(container.read(quizControllerProvider).currentQuestionNumber % 5 == 0, isFalse);

      controller.onAdFinished();
      expect(container.read(quizControllerProvider).currentIndex, 1);
      expect(container.read(quizControllerProvider).step, QuizStep.question);

      // Advance through Question 2, 3, 4
      for (int i = 1; i <= 3; i++) {
        controller.selectOption(0);
        controller.submitCurrentAnswer();
        expect(container.read(quizControllerProvider).step, QuizStep.ad);
        expect(container.read(quizControllerProvider).currentQuestionNumber % 5 == 0, isFalse);
        controller.onAdFinished();
      }

      // Question 5 (index 4) -> Video Ad milestone
      expect(container.read(quizControllerProvider).currentIndex, 4);
      expect(container.read(quizControllerProvider).currentQuestionNumber, 5);
      controller.selectOption(0);
      controller.submitCurrentAnswer();
      expect(container.read(quizControllerProvider).step, QuizStep.ad);
      expect(container.read(quizControllerProvider).currentQuestionNumber % 5 == 0, isTrue);
      controller.onAdFinished();

      // Advance through Question 6, 7, 8, 9
      for (int i = 5; i <= 8; i++) {
        controller.selectOption(0);
        controller.submitCurrentAnswer();
        expect(container.read(quizControllerProvider).step, QuizStep.ad);
        expect(container.read(quizControllerProvider).currentQuestionNumber % 5 == 0, isFalse);
        controller.onAdFinished();
      }

      // Question 10 (index 9) -> Video Ad milestone then Completion
      expect(container.read(quizControllerProvider).currentIndex, 9);
      expect(container.read(quizControllerProvider).currentQuestionNumber, 10);
      controller.selectOption(0);
      controller.submitCurrentAnswer();
      expect(container.read(quizControllerProvider).step, QuizStep.ad);
      expect(container.read(quizControllerProvider).currentQuestionNumber % 5 == 0, isTrue);
      controller.onAdFinished();

      // Final state: Completed with 10 answered questions
      expect(container.read(quizControllerProvider).step, QuizStep.completed);
      expect(container.read(quizControllerProvider).userAnswers.length, 10);
      expect(container.read(quizControllerProvider).earnedAmount, 15.00);
    });

    test('submitAnswerAndAdvance advances questions directly with reward credit', () {
      final container = ProviderContainer();
      final controller = container.read(quizControllerProvider.notifier);

      controller.selectOption(1);
      controller.submitAnswerAndAdvance();

      final stateAfterQ1 = container.read(quizControllerProvider);
      expect(stateAfterQ1.currentIndex, 1);
      expect(stateAfterQ1.currentQuestionNumber, 2);
      expect(stateAfterQ1.selectedOptionIndex, isNull);
      expect(stateAfterQ1.step, QuizStep.question);
      expect(stateAfterQ1.earnedAmount, 1.50);
      expect(stateAfterQ1.totalCoinsEarned, 150);
      expect(stateAfterQ1.userAnswers[0], 1);
    });

    test('flagAdNotShown tracks skipped ads for backend reward reconciliation', () {
      final container = ProviderContainer();
      final controller = container.read(quizControllerProvider.notifier);

      expect(container.read(quizControllerProvider).skippedAdQuestions, isEmpty);

      controller.flagAdNotShown(questionNumber: 2, reason: 'NotReadyOrLoadFailed');
      controller.flagAdNotShown(questionNumber: 4, reason: 'FailedToShow: Network timeout');

      final state = container.read(quizControllerProvider);
      expect(state.skippedAdQuestions, containsAll([2, 4]));
      expect(state.skippedAdQuestions.length, 2);
    });

    test('recordRewardedAdConfirmed and flagRewardAdUnconfirmed track milestone video ads', () {
      final container = ProviderContainer();
      final controller = container.read(quizControllerProvider.notifier);

      expect(container.read(quizControllerProvider).confirmedRewardMilestones, isEmpty);
      expect(container.read(quizControllerProvider).unconfirmedRewardMilestones, isEmpty);

      // Confirm Question 5 milestone
      controller.recordRewardedAdConfirmed(
        questionNumber: 5,
        rewardAmount: 150,
        rewardType: 'coins',
      );
      expect(container.read(quizControllerProvider).confirmedRewardMilestones, [5]);

      // Flag Question 10 milestone as unconfirmed
      controller.flagRewardAdUnconfirmed(
        questionNumber: 10,
        reason: 'AdNotReadyOrLoadFailed',
      );
      expect(container.read(quizControllerProvider).unconfirmedRewardMilestones, [10]);
    });
  });
}
