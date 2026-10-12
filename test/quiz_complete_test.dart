import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/mcq/screens/quiz_complete_screen.dart';

void main() {
  testWidgets('Complete screen shows syncing state when all confirmed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizCompleteScreen(
          earnedAmount: 15.0,
          totalCoins: 1500,
          totalQuestions: 10,
          confirmedMilestones: 2,
          unconfirmedMilestones: 0,
        ),
      ),
    );

    expect(find.text('1500 Coins earned'), findsOneWidget);
    expect(find.textContaining('syncing to your wallet'), findsOneWidget);
    expect(find.text('2 of 2 confirmed'), findsOneWidget);
    expect(find.text('View Wallet'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });

  testWidgets('Complete screen shows pending review state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuizCompleteScreen(
          earnedAmount: 15.0,
          totalCoins: 1500,
          totalQuestions: 10,
          confirmedMilestones: 1,
          unconfirmedMilestones: 1,
        ),
      ),
    );

    expect(find.textContaining('pending review'), findsOneWidget);
    expect(find.text('1 of 2 confirmed'), findsOneWidget);
  });
}
