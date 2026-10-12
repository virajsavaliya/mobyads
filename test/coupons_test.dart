import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/coupons/controllers/coupon_controller.dart';
import 'package:mobyads/features/coupons/models/coupon_model.dart';
import 'package:mobyads/features/coupons/screens/coupons_screen.dart';

void main() {
  test('CouponController filters, parses, and redeems', () {
    final container = ProviderContainer();
    final notifier = container.read(couponControllerProvider.notifier);

    expect(notifier.forStatus(CouponStatus.available).length, 2);
    expect(notifier.forStatus(CouponStatus.used).length, 1);
    expect(notifier.forStatus(CouponStatus.expired).length, 1);

    // fromJson maps backend statuses
    final parsed = Coupon.fromJson({
      'id': 'x',
      'code': 'ABC',
      'title': 'T',
      'value': 25,
      'status': 'REDEEMED',
    });
    expect(parsed.status, CouponStatus.used);

    // Redeem moves available -> used; second redeem fails
    final id = notifier.forStatus(CouponStatus.available).first.id;
    expect(notifier.redeem(id), true);
    expect(notifier.redeem(id), false);
    expect(
      container
          .read(couponControllerProvider)
          .firstWhere((c) => c.id == id)
          .status,
      CouponStatus.used,
    );
    container.dispose();
  });

  testWidgets('CouponsScreen shows tabs and reveals code', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CouponsScreen()),
      ),
    );

    expect(find.widgetWithText(Tab, 'Available'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Used'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Expired'), findsOneWidget);
    expect(find.text('Reveal code'), findsNWidgets(2));

    // Reveal first coupon code + copy affordance
    await tester.tap(find.text('Reveal code').first);
    await tester.pumpAndSettle();
    expect(find.text('MOBY100'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });
}
