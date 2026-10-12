import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../models/server_contract.dart';
import '../models/transaction_model.dart';
import '../services/wallet_service.dart';

class WalletState {
  final double availableBalance;
  final double pendingBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final List<TransactionModel> transactions;
  final bool isRefreshing;

  const WalletState({
    this.availableBalance = 0,
    this.pendingBalance = 0,
    this.totalEarned = 0,
    this.totalWithdrawn = 0,
    required this.transactions,
    this.isRefreshing = false,
  });

  /// Group transactions into human-readable date categories:
  /// "Today", "Yesterday", "This Week", "Earlier"
  Map<String, List<TransactionModel>> get groupedTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: now.weekday - 1));

    final Map<String, List<TransactionModel>> groups = {};

    for (final tx in transactions) {
      final txDate = DateTime(tx.timestamp.year, tx.timestamp.month, tx.timestamp.day);

      String category;
      if (txDate == today) {
        category = 'Today';
      } else if (txDate == yesterday) {
        category = 'Yesterday';
      } else if (txDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        category = 'This Week';
      } else {
        category = 'Earlier';
      }

      if (!groups.containsKey(category)) {
        groups[category] = [];
      }
      groups[category]!.add(tx);
    }

    return groups;
  }

  WalletState copyWith({
    double? availableBalance,
    double? pendingBalance,
    double? totalEarned,
    double? totalWithdrawn,
    List<TransactionModel>? transactions,
    bool? isRefreshing,
  }) {
    return WalletState(
      availableBalance: availableBalance ?? this.availableBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      transactions: transactions ?? this.transactions,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(ApiClient());
});

final walletControllerProvider =
    StateNotifierProvider<WalletController, WalletState>((ref) {
  return WalletController(service: ref.read(walletServiceProvider));
});

class WalletController extends StateNotifier<WalletState> {
  final WalletService? _service;
  bool loadedFromServer = false;

  // ignore: prefer_initializing_formals
  WalletController({WalletService? service})
      // ignore: prefer_initializing_formals
      : _service = service,
        super(WalletState(transactions: _initialMockTransactions));

  // Fresh accounts start empty: no dummy balance, no dummy history.
  // Earnings appear only after real quiz/ad completions.
  static final List<TransactionModel> _initialMockTransactions =
      <TransactionModel>[];

  /// Pull-to-refresh: try ledger first, fall back to local mocks offline.
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    try {
      await refreshFromServer();
    } on DioException {
      await Future.delayed(const Duration(milliseconds: 600));
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  Future<void> refreshFromServer() async {
    final service = _service;
    if (service == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      return;
    }
    final ledger = await service.getWallet();
    final txns = await service.getTransactions();
    state = state.copyWith(
      availableBalance: ledger.available,
      pendingBalance: ledger.pending,
      totalEarned: ledger.totalEarned,
      totalWithdrawn: ledger.totalWithdrawn,
      transactions: txns.map(_fromLedger).toList(),
    );
    loadedFromServer = true;
  }

  static TransactionModel _fromLedger(LedgerTransaction l) {
    final isWithdrawal = l.sourceType == 'WITHDRAWAL';
    TransactionType type;
    switch (l.sourceType) {
      case 'MCQ':
        type = TransactionType.quizReward;
        break;
      case 'AD_REWARD':
        type = TransactionType.videoAd;
        break;
      case 'WITHDRAWAL':
        type = TransactionType.withdrawal;
        break;
      case 'REFERRAL':
        type = TransactionType.referralBonus;
        break;
      default:
        type = TransactionType.dailyBonus;
    }
    TransactionStatus status;
    switch (l.status) {
      case LedgerStatus.pending:
        status = TransactionStatus.pending;
        break;
      case LedgerStatus.withdrawn:
        status = TransactionStatus.withdrawn;
        break;
      default:
        status = TransactionStatus.available;
    }
    return TransactionModel(
      id: l.id,
      title: '${l.sourceType} reward',
      amount: l.amount,
      isCredit: !isWithdrawal,
      timestamp: DateTime.now(),
      status: status,
      type: type,
      referenceId: l.sourceId,
    );
  }
}
