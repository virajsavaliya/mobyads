import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/wallet/models/transaction_model.dart';
import 'package:mobyads/features/wallet/widgets/transaction_detail_sheet.dart';

TransactionModel sample({TransactionStatus status = TransactionStatus.pending}) {
  return TransactionModel(
    id: 'tx_test_1',
    title: 'Daily News Quiz Reward',
    amount: 15.0,
    isCredit: true,
    timestamp: DateTime(2026, 10, 12, 10, 30),
    status: status,
    type: TransactionType.quizReward,
    referenceId: 'REF-123',
  );
}

void main() {
  test('statusReason explains every status', () {
    expect(statusReason(TransactionStatus.available), contains('withdrawal'));
    expect(statusReason(TransactionStatus.pending), contains('24h'));
    expect(statusReason(TransactionStatus.withdrawn), contains('Paid out'));
  });

  testWidgets('Sheet shows reason, hides IDs until Details tapped', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionDetailSheet(transaction: sample()),
        ),
      ),
    );

    expect(find.text('Daily News Quiz Reward'), findsOneWidget);
    expect(find.textContaining('24h fraud check'), findsOneWidget);
    expect(find.text('tx_test_1'), findsNothing);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.text('tx_test_1'), findsOneWidget);
    expect(find.text('REF-123'), findsOneWidget);
  });
}
