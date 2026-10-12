import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/profile/screens/privacy_policy_screen.dart';
import 'package:mobyads/features/profile/screens/terms_conditions_screen.dart';

void main() {
  testWidgets('Privacy Policy has Read-mode TOC + sections', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyPolicyScreen()),
    );

    expect(find.text('Contents'), findsOneWidget);
    expect(find.textContaining('Information We Collect'), findsWidgets);
    expect(find.textContaining('Your Rights'), findsWidgets);
  });

  testWidgets('Terms has Read-mode TOC + sections', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TermsConditionsScreen()),
    );

    expect(find.text('Contents'), findsOneWidget);
    expect(find.textContaining('Eligibility'), findsWidgets);
    expect(find.textContaining('Anti-Fraud'), findsWidgets);
  });

  testWidgets('TOC tap scrolls without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyPolicyScreen()),
    );

    await tester.tap(find.textContaining('Security & Data').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Security & Data'), findsWidgets);
  });
}
