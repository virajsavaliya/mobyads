import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/wallet/controllers/wallet_controller.dart';
import 'package:mobyads/features/withdrawals/controllers/withdraw_controller.dart';

void main() {
  group('Wallet & Withdrawal Functional Validation', () {
    test('WalletController starts empty for fresh accounts', () {
      final container = ProviderContainer();
      final wallet = container.read(walletControllerProvider);

      expect(wallet.availableBalance, 0);
      expect(wallet.pendingBalance, 0);
      expect(wallet.totalEarned, 0);
      expect(wallet.totalWithdrawn, 0);
      expect(wallet.transactions, isEmpty);

      // No groups for a fresh account
      expect(wallet.groupedTransactions, isEmpty);
    });

    test('WithdrawController manages selected payout method and masked account', () {
      final container = ProviderContainer();
      final withdrawState = container.read(withdrawControllerProvider);

      expect(withdrawState.selectedPayoutMethod, isNotNull);
      expect(withdrawState.selectedPayoutMethod!.maskedAccountNumber, '•••• 4521');
      expect(withdrawState.selectedPayoutMethod!.bankName, 'HDFC Bank');
    });

    test('WithdrawController submits withdrawal and returns reference ID', () async {
      final container = ProviderContainer();
      final controller = container.read(withdrawControllerProvider.notifier);

      final refId = await controller.submitWithdrawal(50.0);
      expect(refId, isNotNull);
      expect(refId!.startsWith('WDR-'), isTrue);
      expect(container.read(withdrawControllerProvider).isSubmitting, isFalse);
    });
  });
}
