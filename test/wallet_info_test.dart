import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/wallet/screens/wallet_screen.dart';

void main() {
  testWidgets('Wallet info dialog shows server-driven minimum', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WalletScreen()),
      ),
    );

    await tester.tap(find.byTooltip('Wallet & Payout Info'));
    await tester.pumpAndSettle();

    expect(find.text('Wallet Info'), findsOneWidget);
    // Server default fallback is ₹50.00 (was hardcoded ₹10.00)
    expect(find.textContaining('Minimum Withdrawal: ₹50.00'), findsOneWidget);
  });
}
