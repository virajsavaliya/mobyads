import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/withdrawals/widgets/withdrawal_status_stepper.dart';
import 'package:mobyads/models/server_contract.dart';

void main() {
  testWidgets('Stepper shows all four lifecycle labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WithdrawalStatusStepper(
            status: WithdrawalServerStatus.processing,
          ),
        ),
      ),
    );

    expect(find.text('Requested'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.textContaining('Reserved funds'), findsNothing);
  });

  testWidgets('Failed status shows reason + funds-returned message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WithdrawalStatusStepper(
            status: WithdrawalServerStatus.failed,
            failureReason: 'Provider timeout',
          ),
        ),
      ),
    );

    expect(find.textContaining('Provider timeout'), findsOneWidget);
    expect(find.textContaining('Reserved funds were returned'), findsOneWidget);
  });

  testWidgets('Rejected status shows rejected label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WithdrawalStatusStepper(
            status: WithdrawalServerStatus.rejected,
          ),
        ),
      ),
    );

    expect(find.textContaining('Rejected'), findsOneWidget);
  });
}
