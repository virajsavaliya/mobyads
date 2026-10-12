import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/auth/controllers/auth_controller.dart';
import 'package:mobyads/features/profile/controllers/notification_preferences_controller.dart';
import 'package:mobyads/features/profile/screens/about_screen.dart';
import 'package:mobyads/features/profile/screens/edit_profile_screen.dart';
import 'package:mobyads/features/profile/screens/help_support_screen.dart';
import 'package:mobyads/features/profile/screens/notification_preferences_screen.dart';
import 'package:mobyads/features/profile/screens/payout_methods_screen.dart';
import 'package:mobyads/features/profile/screens/privacy_policy_screen.dart';
import 'package:mobyads/features/profile/screens/profile_screen.dart';
import 'package:mobyads/features/profile/screens/terms_conditions_screen.dart';
import 'package:mobyads/features/withdrawals/controllers/withdraw_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Profile Menu Screens & Sub-States Tests', () {
    testWidgets('EditProfileScreen dirty checking and save functionality',
        (tester) async {
      final container = ProviderContainer();
      container.read(authControllerProvider.notifier).updateProfile(
            name: 'Alex Johnson',
            email: 'alex.johnson@example.com',
            phone: '+91 9876543210',
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify fields prefilled
      expect(find.text('Alex Johnson'), findsWidgets);
      expect(find.text('alex.johnson@example.com'), findsWidgets);

      // Verify Save button is initially disabled (not dirty)
      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save Changes');
      expect(saveButtonFinder, findsOneWidget);
      final initialButton = tester.widget<ElevatedButton>(saveButtonFinder);
      expect(initialButton.onPressed, isNull);

      // Change full name
      final nameFieldFinder = find.byType(TextFormField).first;
      await tester.enterText(nameFieldFinder, 'Alex Updated');
      await tester.pumpAndSettle();

      // Verify Save button is now enabled
      var enabledButton = tester.widget<ElevatedButton>(saveButtonFinder);
      expect(enabledButton.onPressed, isNotNull);

      // Revert name back to original
      await tester.enterText(nameFieldFinder, 'Alex Johnson');
      await tester.pumpAndSettle();

      // Verify Save button is disabled again
      var revertedButton = tester.widget<ElevatedButton>(saveButtonFinder);
      expect(revertedButton.onPressed, isNull);

      // Change again and save
      await tester.enterText(nameFieldFinder, 'Alex Updated');
      await tester.pumpAndSettle();

      // Scroll into view & Tap Save
      await tester.ensureVisible(saveButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Verify user updated in provider
      final updatedUser = container.read(authControllerProvider).user;
      expect(updatedUser?.name, equals('Alex Updated'));
    });

    testWidgets('PayoutMethodsScreen lists accounts and supports removal to empty state',
        (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PayoutMethodsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify default method rendered
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('•••• 4521 · HDFC0001234'), findsOneWidget);

      // Remove the only payout method
      container.read(withdrawControllerProvider.notifier).removePayoutMethod('pay_01');
      await tester.pumpAndSettle();

      // Verify correct empty state is displayed
      expect(find.text('No Payout Methods Added'), findsOneWidget);
      expect(find.text('Add a bank account or Paytm wallet to receive your quiz rewards'), findsOneWidget);
      expect(find.text('Add New Method'), findsOneWidget);
    });

    testWidgets('NotificationPreferencesScreen toggles and updates state',
        (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: NotificationPreferencesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 4 switch items present
      expect(find.text('Task Reminders'), findsOneWidget);
      expect(find.text('Reward Credited'), findsOneWidget);
      expect(find.text('Withdrawal Updates'), findsOneWidget);
      expect(find.text('Coupon & Offers'), findsOneWidget);

      // Initial state of task reminders is true
      expect(
        container.read(notificationPreferencesProvider).taskReminders,
        isTrue,
      );

      // Toggle first switch
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(4));

      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Verify state updated to false
      expect(
        container.read(notificationPreferencesProvider).taskReminders,
        isFalse,
      );
    });

    testWidgets(
        'PrivacyPolicyScreen and TermsConditionsScreen render structured sections',
        (tester) async {
      // 1. Privacy Policy
      await tester.pumpWidget(
        const MaterialApp(home: PrivacyPolicyScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Contents'), findsOneWidget);
      expect(find.text('1. Information We Collect'), findsWidgets);
      expect(find.text('3. Ad Telemetry & Tracking'), findsWidgets);

      // 2. Terms & Conditions
      await tester.pumpWidget(
        const MaterialApp(home: TermsConditionsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Contents'), findsOneWidget);
      expect(find.text('1. Eligibility & User Account'), findsWidgets);
      expect(find.text('4. Anti-Fraud & Prohibited Conduct'), findsWidgets);
    });

    testWidgets('HelpSupportScreen renders FAQ search and expandable items',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HelpSupportScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('How do I earn money on MobyAds?'), findsOneWidget);
      expect(find.text('Still need help?'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);

      // Test Search query filter
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'VPN');
      await tester.pumpAndSettle();

      expect(find.text('Can I use a VPN or multiple accounts?'), findsOneWidget);
      expect(find.text('How do I earn money on MobyAds?'), findsNothing);
    });

    testWidgets('AboutScreen renders app details and links', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('About MobyAds'), findsOneWidget);
      expect(find.text('MobyAds'), findsOneWidget);
      expect(find.text('Official Website'), findsOneWidget);
      expect(find.text('Rate MobyAds'), findsOneWidget);
      expect(find.text('Share with Friends'), findsOneWidget);
      expect(find.text('© 2026 MobyAds Inc. All rights reserved.'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders exactly 8 menu items and no Admin/MCQ items', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exactly the 8 required items:
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Payout Methods'), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('About MobyAds'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      // Confirm Admin/MCQ Review Queue is completely absent
      expect(find.text('Admin MCQ Review Queue'), findsNothing);
      expect(find.text('Admin'), findsNothing);

      container.dispose();
    });
  });
}
