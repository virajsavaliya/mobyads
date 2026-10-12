enum TransactionStatus {
  available,
  pending,
  withdrawn,
}

enum TransactionType {
  quizReward,
  videoAd,
  withdrawal,
  referralBonus,
  dailyBonus,
}

/// Model for Wallet Transaction History
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final bool isCredit;
  final DateTime timestamp;
  final TransactionStatus status;
  final TransactionType type;
  final String? referenceId;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isCredit,
    required this.timestamp,
    required this.status,
    required this.type,
    this.referenceId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isCredit: json['is_credit'] as bool? ?? true,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.available,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.quizReward,
      ),
      referenceId: json['reference_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'is_credit': isCredit,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'type': type.name,
        'reference_id': referenceId,
      };
}
