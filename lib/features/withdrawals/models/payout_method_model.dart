/// Type of payout destination
enum PayoutMethodType {
  bankAccount,
  paytm;

  String get displayName {
    switch (this) {
      case PayoutMethodType.bankAccount:
        return 'Bank Account';
      case PayoutMethodType.paytm:
        return 'Paytm';
    }
  }
}

/// Payout Method domain model (Bank Account / Paytm)
class PayoutMethod {
  final String id;
  final PayoutMethodType type;
  final String holderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String? paytmNumber;
  final bool isDefault;

  const PayoutMethod({
    required this.id,
    this.type = PayoutMethodType.bankAccount,
    required this.holderName,
    this.accountNumber = '',
    this.ifscCode = '',
    this.bankName = 'Bank Account',
    this.paytmNumber,
    this.isDefault = false,
  });

  bool get isBankAccount => type == PayoutMethodType.bankAccount;
  bool get isPaytm => type == PayoutMethodType.paytm;

  /// Masked Bank Account Number (e.g., '•••• 4521')
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    final last4 = accountNumber.substring(accountNumber.length - 4);
    return '•••• $last4';
  }

  /// Masked Paytm Mobile Number (e.g., '•••• •••• 91')
  String get maskedPaytmNumber {
    final number = paytmNumber ?? '';
    if (number.length < 2) return number;
    final last2 = number.substring(number.length - 2);
    return '•••• •••• $last2';
  }

  /// Unified masked identifier depending on method type
  String get maskedIdentifier {
    if (isPaytm) {
      return maskedPaytmNumber;
    }
    return maskedAccountNumber;
  }

  /// Primary title for cards
  String get title {
    if (isPaytm) {
      return 'Paytm';
    }
    return bankName.isNotEmpty ? bankName : 'Bank Account';
  }

  /// Secondary subtitle for cards
  String get subtitle {
    if (isPaytm) {
      return '$maskedPaytmNumber · Linked Mobile';
    }
    if (ifscCode.isNotEmpty) {
      return '$maskedAccountNumber · $ifscCode';
    }
    return maskedAccountNumber;
  }

  PayoutMethod copyWith({
    String? id,
    PayoutMethodType? type,
    String? holderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? paytmNumber,
    bool? isDefault,
  }) {
    return PayoutMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      holderName: holderName ?? this.holderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      paytmNumber: paytmNumber ?? this.paytmNumber,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
