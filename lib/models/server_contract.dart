// M2-M3 server-authoritative DTOs (mirrors backend/openapi.yaml).
// Wire format is snake_case; correct answers NEVER appear here (PDF §7).

enum ServerAccountStatus { normal, review, blocked }

enum ServerVerificationStatus { verified, unverified }

enum LedgerStatus { pending, available, withdrawn, reversed, failed }

enum WithdrawalServerStatus {
  pending,
  approved,
  processing,
  paid,
  failed,
  rejected,
}

class ServerUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? country;
  final ServerAccountStatus accountStatus;
  final ServerVerificationStatus verificationStatus;

  const ServerUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.country,
    this.accountStatus = ServerAccountStatus.normal,
    this.verificationStatus = ServerVerificationStatus.unverified,
  });

  factory ServerUser.fromJson(Map<String, dynamic> json) {
    ServerAccountStatus statusFrom(String? v) {
      switch (v) {
        case 'REVIEW':
          return ServerAccountStatus.review;
        case 'BLOCKED':
          return ServerAccountStatus.blocked;
        default:
          return ServerAccountStatus.normal;
      }
    }

    return ServerUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      accountStatus: statusFrom(json['account_status'] as String?),
      verificationStatus:
          (json['verification_status'] as String?) == 'VERIFIED'
              ? ServerVerificationStatus.verified
              : ServerVerificationStatus.unverified,
    );
  }
}

/// Public question: no correctOptionIndex by design.
class PublicQuestion {
  final String id;
  final String text;
  final List<String> options;
  final String category;
  final double rewardAmount;
  final String rewardCurrency;

  const PublicQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.category,
    required this.rewardAmount,
    this.rewardCurrency = 'INR',
  });

  factory PublicQuestion.fromJson(Map<String, dynamic> json) {
    return PublicQuestion(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      category: json['category'] as String? ?? 'GENERAL',
      rewardAmount:
          (json['reward_amount'] as num?)?.toDouble() ?? 0.0,
      rewardCurrency: json['reward_currency'] as String? ?? 'INR',
    );
  }
}

class LedgerTransaction {
  final String id;
  final String sourceType;
  final String sourceId;
  final double amount;
  final String currency;
  final LedgerStatus status;

  const LedgerTransaction({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory LedgerTransaction.fromJson(Map<String, dynamic> json) {
    LedgerStatus statusFrom(String? v) {
      switch (v) {
        case 'AVAILABLE':
          return LedgerStatus.available;
        case 'WITHDRAWN':
          return LedgerStatus.withdrawn;
        case 'REVERSED':
          return LedgerStatus.reversed;
        case 'FAILED':
          return LedgerStatus.failed;
        default:
          return LedgerStatus.pending;
      }
    }

    return LedgerTransaction(
      id: json['id'] as String? ?? '',
      sourceType: json['source_type'] as String? ?? '',
      sourceId: json['source_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      status: statusFrom(json['status'] as String?),
    );
  }
}

/// POST /quizzes/submit body — retry-safe via idempotencyKey (PDF §7).
Map<String, dynamic> quizSubmitBody({
  required String questionId,
  required int selectedIndex,
  required String idempotencyKey,
}) =>
    {
      'question_id': questionId,
      'selected_index': selectedIndex,
      'idempotency_key': idempotencyKey,
    };

/// POST /withdrawals body — duplicate-submit safe (PDF §16).
Map<String, dynamic> withdrawalBody({
  required double amount,
  required String payoutMethodId,
  required String idempotencyKey,
}) =>
    {
      'amount': amount,
      'payout_method_id': payoutMethodId,
      'idempotency_key': idempotencyKey,
    };
