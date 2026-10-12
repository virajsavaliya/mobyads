/// User domain model
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? referralCode;
  final num coinBalance;
  final DateTime? createdAt;
  final String? country;
  final String? dateOfBirth;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.referralCode,
    this.coinBalance = 0,
    this.createdAt,
    this.country,
    this.dateOfBirth,
    this.avatarUrl,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? referralCode,
    num? coinBalance,
    DateTime? createdAt,
    String? country,
    String? dateOfBirth,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      referralCode: referralCode ?? this.referralCode,
      coinBalance: coinBalance ?? this.coinBalance,
      createdAt: createdAt ?? this.createdAt,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      referralCode: json['referral_code'] as String?,
      coinBalance: json['coin_balance'] as num? ?? 0,
      country: json['country'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'referral_code': referralCode,
        'coin_balance': coinBalance,
        'country': country,
        'date_of_birth': dateOfBirth,
        'avatar_url': avatarUrl,
        'created_at': createdAt?.toIso8601String(),
      };
}
