/// Wallet balance and transaction model
class WalletModel {
  final num coinBalance;
  final num cashEquivalent;
  final num totalEarned;
  final num totalWithdrawn;

  const WalletModel({
    this.coinBalance = 0,
    this.cashEquivalent = 0.0,
    this.totalEarned = 0,
    this.totalWithdrawn = 0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      coinBalance: json['coin_balance'] as num? ?? 0,
      cashEquivalent: json['cash_equivalent'] as num? ?? 0.0,
      totalEarned: json['total_earned'] as num? ?? 0,
      totalWithdrawn: json['total_withdrawn'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'coin_balance': coinBalance,
        'cash_equivalent': cashEquivalent,
        'total_earned': totalEarned,
        'total_withdrawn': totalWithdrawn,
      };
}
