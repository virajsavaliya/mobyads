import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/wallet/models/transaction_model.dart';

void main() {
  group('Wallet & Transactions Unit Tests', () {
    test('TransactionModel calculates credit/debit sign correctly', () {
      final earning = TransactionModel(
        id: 'tx_1',
        title: 'Quiz Reward',
        amount: 15.0,
        isCredit: true,
        timestamp: DateTime.now(),
        type: TransactionType.quizReward,
        status: TransactionStatus.available,
      );

      final withdrawal = TransactionModel(
        id: 'tx_2',
        title: 'Bank Payout',
        amount: 50.0,
        isCredit: false,
        timestamp: DateTime.now(),
        type: TransactionType.withdrawal,
        status: TransactionStatus.withdrawn,
      );

      expect(earning.isCredit, isTrue);
      expect(withdrawal.isCredit, isFalse);
      expect(earning.status, TransactionStatus.available);
      expect(withdrawal.status, TransactionStatus.withdrawn);
    });
  });
}
