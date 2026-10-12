import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/config/app_constants.dart';
import 'package:mobyads/features/auth/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Onboarding shows one idea per slide + Skip', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(home: OnboardingScreen(onFinish: null)),
    );

    expect(find.text('Answer daily quizzes'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Get started on last slide persists flag + finishes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onFinish: () => finished = true),
      ),
    );

    // Advance through slides
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Watch sponsor ads'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Withdraw real money'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AppConstants.onboardingKey), isTrue);
  });

  testWidgets('Skip persists flag + finishes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(onFinish: () => finished = true),
      ),
    );

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AppConstants.onboardingKey), isTrue);
  });
}
