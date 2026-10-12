import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/profile/screens/payout_methods_screen.dart';
import 'package:mobyads/features/withdrawals/controllers/withdraw_controller.dart';
import 'package:mobyads/features/withdrawals/models/payout_method_model.dart';
import 'package:mobyads/features/withdrawals/screens/withdraw_screen.dart';
import 'package:mobyads/features/withdrawals/widgets/add_payout_method_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PayoutMethod Model & Controller Unit Tests', () {
    test('Bank Account PayoutMethod masks account number and formats title/subtitle', () {
      const bankMethod = PayoutMethod(
        id: 'bank_1',
        type: PayoutMethodType.bankAccount,
        holderName: 'Alex Johnson',
        bankName: 'HDFC Bank',
        accountNumber: '98765432104521',
        ifscCode: 'HDFC0001234',
        isDefault: true,
      );

      expect(bankMethod.isBankAccount, isTrue);
      expect(bankMethod.isPaytm, isFalse);
      expect(bankMethod.maskedAccountNumber, '•••• 4521');
      expect(bankMethod.maskedIdentifier, '•••• 4521');
      expect(bankMethod.title, 'HDFC Bank');
      expect(bankMethod.subtitle, '•••• 4521 · HDFC0001234');
    });

    test('Paytm PayoutMethod masks mobile number and formats title/subtitle', () {
      const paytmMethod = PayoutMethod(
        id: 'paytm_1',
        type: PayoutMethodType.paytm,
        holderName: 'Priya Sharma',
        paytmNumber: '9876543291',
        isDefault: false,
      );

      expect(paytmMethod.isPaytm, isTrue);
      expect(paytmMethod.isBankAccount, isFalse);
      expect(paytmMethod.maskedPaytmNumber, '•••• •••• 91');
      expect(paytmMethod.maskedIdentifier, '•••• •••• 91');
      expect(paytmMethod.title, 'Paytm');
      expect(paytmMethod.subtitle, '•••• •••• 91 · Linked Mobile');
    });

    test('WithdrawController adds Paytm method alongside existing Bank Account', () {
      final container = ProviderContainer();
      final controller = container.read(withdrawControllerProvider.notifier);

      // Initially has 1 default bank account
      expect(container.read(withdrawControllerProvider).payoutMethods.length, 1);
      expect(
        container.read(withdrawControllerProvider).payoutMethods.first.type,
        PayoutMethodType.bankAccount,
      );

      // Add Paytm method
      controller.addPaytmPayoutMethod(
        holderName: 'Alex Johnson',
        paytmNumber: '9876543291',
      );

      final state = container.read(withdrawControllerProvider);
      expect(state.payoutMethods.length, 2);

      final paytmItem = state.payoutMethods.firstWhere((m) => m.isPaytm);
      expect(paytmItem.holderName, 'Alex Johnson');
      expect(paytmItem.paytmNumber, '9876543291');
      expect(paytmItem.maskedIdentifier, '•••• •••• 91');
      expect(paytmItem.isDefault, isTrue);

      // Bank account is still preserved
      final bankItem = state.payoutMethods.firstWhere((m) => m.isBankAccount);
      expect(bankItem.id, 'pay_01');
      expect(bankItem.isDefault, isFalse);
    });

    test('Removing one payout method does not affect the other when both exist', () {
      final container = ProviderContainer();
      final controller = container.read(withdrawControllerProvider.notifier);

      // Add Paytm
      controller.addPaytmPayoutMethod(
        holderName: 'Alex Johnson',
        paytmNumber: '9876543291',
      );
      expect(container.read(withdrawControllerProvider).payoutMethods.length, 2);

      // Remove Bank Account ('pay_01')
      controller.removePayoutMethod('pay_01');

      final stateAfterBankRemoval = container.read(withdrawControllerProvider);
      expect(stateAfterBankRemoval.payoutMethods.length, 1);
      expect(stateAfterBankRemoval.payoutMethods.first.isPaytm, isTrue);
      expect(stateAfterBankRemoval.payoutMethods.first.paytmNumber, '9876543291');
      expect(stateAfterBankRemoval.selectedPayoutMethod?.isPaytm, isTrue);
    });

    test('Setting default toggles seamlessly between Bank and Paytm', () {
      final container = ProviderContainer();
      final controller = container.read(withdrawControllerProvider.notifier);

      controller.addPaytmPayoutMethod(
        holderName: 'Alex Johnson',
        paytmNumber: '9876543291',
      );

      // Switch default back to bank account
      controller.setAsDefault('pay_01');

      final state = container.read(withdrawControllerProvider);
      final bankItem = state.payoutMethods.firstWhere((m) => m.id == 'pay_01');
      final paytmItem = state.payoutMethods.firstWhere((m) => m.isPaytm);

      expect(bankItem.isDefault, isTrue);
      expect(paytmItem.isDefault, isFalse);
      expect(state.selectedPayoutMethod?.id, 'pay_01');
    });
  });

  group('Add Payout Method Bottom Sheet Widget Tests', () {
    testWidgets('Toggling between Bank Account and Paytm switches form fields dynamically',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Consumer(
                  builder: (ctx, ref, _) => ElevatedButton(
                    onPressed: () => showAddPayoutMethodSheet(context, ref),
                    child: const Text('Open Sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // 1. Initial State: Bank Account form is visible
      expect(find.text('Bank Account'), findsWidgets);
      expect(find.text('Paytm'), findsOneWidget);
      expect(find.text('Bank Name'), findsOneWidget);
      expect(find.text('Bank Account Number'), findsOneWidget);
      expect(find.text('Confirm Account Number'), findsOneWidget);
      expect(find.text('IFSC / Routing Code'), findsOneWidget);
      expect(find.text('Save Bank Account'), findsOneWidget);
      expect(find.text('Paytm Mobile Number'), findsNothing);

      // 2. Tap Paytm option
      await tester.tap(find.text('Paytm'));
      await tester.pumpAndSettle();

      // 3. Paytm form is now active
      expect(find.text('Paytm Mobile Number'), findsOneWidget);
      expect(find.text('+91 '), findsOneWidget);
      expect(find.text('Save Paytm Account'), findsOneWidget);
      expect(find.text('Bank Account Number'), findsNothing);
      expect(find.text('IFSC / Routing Code'), findsNothing);

      // 4. Validate short mobile number error
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Account Holder Name'),
        'Priya Sharma',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Paytm Mobile Number'),
        '12345',
      );
      await tester.tap(find.text('Save Paytm Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid 10-digit mobile number'), findsOneWidget);

      // 5. Enter valid 10-digit number and save
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Paytm Mobile Number'),
        '9876543291',
      );
      await tester.tap(find.text('Save Paytm Account'));
      await tester.pumpAndSettle();

      // Bottom sheet closed and success snackbar displayed
      expect(find.text('Paytm account added successfully!'), findsOneWidget);
    });
  });

  group('Withdraw Screen & Profile Payout Methods UI Tests with Bank and Paytm', () {
    testWidgets('WithdrawScreen renders Paytm payout card with distinct icon and badge',
        (tester) async {
      const paytmMethod = PayoutMethod(
        id: 'paytm_01',
        type: PayoutMethodType.paytm,
        holderName: 'Alex Johnson',
        paytmNumber: '9876543291',
        isDefault: true,
      );

      final container = ProviderContainer(
        overrides: [
          withdrawControllerProvider.overrideWith(
            (ref) => WithdrawController(
              initialState: const WithdrawState(
                payoutMethods: [paytmMethod],
                selectedPayoutMethod: paytmMethod,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: WithdrawScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paytm'), findsOneWidget);
      expect(find.text('WALLET'), findsOneWidget);
      expect(find.text('•••• •••• 91 · Linked Mobile'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    });

    testWidgets('PayoutMethodsScreen displays both Bank and Paytm cards distinguishably',
        (tester) async {
      const bankMethod = PayoutMethod(
        id: 'bank_01',
        type: PayoutMethodType.bankAccount,
        holderName: 'Alex Johnson',
        bankName: 'HDFC Bank',
        accountNumber: '98765432104521',
        ifscCode: 'HDFC0001234',
        isDefault: true,
      );

      const paytmMethod = PayoutMethod(
        id: 'paytm_01',
        type: PayoutMethodType.paytm,
        holderName: 'Alex Johnson',
        paytmNumber: '9876543291',
        isDefault: false,
      );

      final container = ProviderContainer(
        overrides: [
          withdrawControllerProvider.overrideWith(
            (ref) => WithdrawController(
              initialState: const WithdrawState(
                payoutMethods: [bankMethod, paytmMethod],
                selectedPayoutMethod: bankMethod,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PayoutMethodsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Bank card checks
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('•••• 4521 · HDFC0001234'), findsOneWidget);

      // Paytm card checks
      expect(find.text('Paytm'), findsOneWidget);
      expect(find.text('WALLET'), findsOneWidget);
      expect(find.text('•••• •••• 91 · Linked Mobile'), findsOneWidget);

      // Icons check
      expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
    });
  });
}
