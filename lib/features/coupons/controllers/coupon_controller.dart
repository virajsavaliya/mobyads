import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coupon_model.dart';

final couponControllerProvider =
    StateNotifierProvider<CouponController, List<Coupon>>(
        (ref) => CouponController());

class CouponController extends StateNotifier<List<Coupon>> {
  CouponController() : super(_initialMockCoupons);

  static final _now = DateTime.now();
  static final List<Coupon> _initialMockCoupons = [
    Coupon(
      id: 'cpn_01',
      code: 'MOBY100',
      title: '₹100 Cashback Coupon',
      description: 'Flat ₹100 off on partner recharge. Min order ₹199.',
      value: 100,
      expiryDate: _now.add(const Duration(days: 12)),
      status: CouponStatus.available,
    ),
    Coupon(
      id: 'cpn_02',
      code: 'EARN50',
      title: '₹50 Bonus Coupon',
      description: 'Extra ₹50 on your next quiz milestone.',
      value: 50,
      expiryDate: _now.add(const Duration(days: 5)),
      status: CouponStatus.available,
    ),
    Coupon(
      id: 'cpn_03',
      code: 'USED20',
      title: '₹20 Redeemed Coupon',
      description: 'Redeemed on partner store.',
      value: 20,
      expiryDate: _now.subtract(const Duration(days: 1)),
      status: CouponStatus.used,
    ),
    Coupon(
      id: 'cpn_04',
      code: 'OLD10',
      title: '₹10 Expired Coupon',
      description: 'Validity ended last week.',
      value: 10,
      expiryDate: _now.subtract(const Duration(days: 7)),
      status: CouponStatus.expired,
    ),
  ];

  List<Coupon> forStatus(CouponStatus status) =>
      state.where((c) => c.status == status).toList();

  /// Marks a coupon redeemed (server would validate + write user_coupons).
  bool redeem(String id) {
    final index = state.indexWhere((c) => c.id == id);
    if (index < 0 || state[index].status != CouponStatus.available) {
      return false;
    }
    final updated = List<Coupon>.from(state);
    updated[index] = updated[index].copyWith(status: CouponStatus.used);
    state = updated;
    return true;
  }
}
