import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../models/server_contract.dart';

// Ledger-derived wallet read (PDF §8, §14). Balance is derived, never set.
class WalletLedger {
  final double available;
  final double pending;
  final double totalEarned;
  final double totalWithdrawn;
  final String currency;

  const WalletLedger({
    this.available = 0,
    this.pending = 0,
    this.totalEarned = 0,
    this.totalWithdrawn = 0,
    this.currency = 'INR',
  });

  factory WalletLedger.fromJson(Map<String, dynamic> json) {
    double d(Object? v, double fb) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? fb;
    return WalletLedger(
      available: d(json['available'], 0),
      pending: d(json['pending'], 0),
      totalEarned: d(json['total_earned'] ?? json['totalEarned'], 0),
      totalWithdrawn:
          d(json['total_withdrawn'] ?? json['totalWithdrawn'], 0),
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}

class WalletService {
  final ApiClient _api;
  WalletService(this._api);

  Future<WalletLedger> getWallet() async {
    final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.wallet);
    return WalletLedger.fromJson(res.data ?? const {});
  }

  Future<List<LedgerTransaction>> getTransactions() async {
    final res =
        await _api.get<Map<String, dynamic>>(ApiEndpoints.transactions);
    final list = res.data?['transactions'] as List? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(LedgerTransaction.fromJson)
        .toList();
  }
}
