import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/ads/widgets/app_banner_ad.dart';
import 'package:mobyads/features/mcq/controllers/quiz_controller.dart';
import 'package:mobyads/features/mcq/screens/quiz_screen.dart';

void main() {
  group('QuizScreen Distilled Banner & Direct Advance Tests', () {
    testWidgets('QuizScreen renders a single bottom banner strip on question screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: QuizScreen(),
          ),
        ),
      );

      // Distilled: one bottom placement only (top strip removed)
      expect(find.byType(ContainerBannerStrip), findsOneWidget);
      expect(find.byType(AppBannerAd), findsOneWidget);

      // Verify Question 1 header and options
      expect(find.text('Question 1 of 10'), findsOneWidget);
      expect(find.text('Next Question'), findsOneWidget);
    });

    testWidgets('Answering Question 1 directly advances to Question 2 without interstitial interruption', (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: QuizScreen(),
          ),
        ),
      );

      // Initial state: Question 1
      expect(find.text('Question 1 of 10'), findsOneWidget);

      // Select Option A (index 0)
      container.read(quizControllerProvider.notifier).selectOption(0);
      await tester.pumpAndSettle();

      // Tap Next Question button
      await tester.tap(find.text('Next Question'));
      await tester.pumpAndSettle();

      // Directly advances to Question 2 of 10
      expect(find.text('Question 2 of 10'), findsOneWidget);
      expect(container.read(quizControllerProvider).currentIndex, 1);

      await tester.pumpAndSettle();
      container.dispose();
    });

    testWidgets('Question 5 shows milestone button text', (WidgetTester tester) async {
      final container = ProviderContainer();
      final controller = container.read(quizControllerProvider.notifier);

      // Fast forward to Question 5
      for (int i = 0; i < 4; i++) {
        controller.selectOption(0);
        controller.submitAnswerAndAdvance();
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: QuizScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Question 5 of 10'), findsOneWidget);
      expect(find.text('Watch Video & Continue'), findsOneWidget);
      expect(find.text('Milestone Reward'), findsOneWidget);

      await tester.pumpAndSettle();
      container.dispose();
    });
  });
}
