enum CouponStatus { available, used, expired }

/// User coupon (mirrors backend coupons/user_coupons, PDF §13).
class Coupon {
  final String id;
  final String code;
  final String title;
  final String? description;
  final double value;
  final String type;
  final DateTime? expiryDate;
  final CouponStatus status;

  const Coupon({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.value,
    this.type = 'CASHBACK',
    this.expiryDate,
    this.status = CouponStatus.available,
  });

  Coupon copyWith({CouponStatus? status}) => Coupon(
        id: id,
        code: code,
        title: title,
        description: description,
        value: value,
        type: type,
        expiryDate: expiryDate,
        status: status ?? this.status,
      );

  factory Coupon.fromJson(Map<String, dynamic> json) {
    CouponStatus statusFrom(String? v) {
      switch (v) {
        case 'REDEEMED':
        case 'used':
          return CouponStatus.used;
        case 'EXPIRED':
        case 'expired':
          return CouponStatus.expired;
        default:
          return CouponStatus.available;
      }
    }

    return Coupon(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      value: (json['value'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String? ?? 'CASHBACK',
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'] as String)
          : null,
      status: statusFrom(json['status'] as String?),
    );
  }
}
