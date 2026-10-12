import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payout_method_model.dart';

class WithdrawState {
  final List<PayoutMethod> payoutMethods;
  final PayoutMethod? selectedPayoutMethod;
  final bool isSubmitting;
  final String? lastReferenceId;

  const WithdrawState({
    required this.payoutMethods,
    this.selectedPayoutMethod,
    this.isSubmitting = false,
    this.lastReferenceId,
  });

  bool get hasPayoutMethod => selectedPayoutMethod != null;

  WithdrawState copyWith({
    List<PayoutMethod>? payoutMethods,
    PayoutMethod? selectedPayoutMethod,
    bool? isSubmitting,
    String? lastReferenceId,
  }) {
    return WithdrawState(
      payoutMethods: payoutMethods ?? this.payoutMethods,
      selectedPayoutMethod: selectedPayoutMethod ?? this.selectedPayoutMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastReferenceId: lastReferenceId ?? this.lastReferenceId,
    );
  }
}

final withdrawControllerProvider =
    StateNotifierProvider<WithdrawController, WithdrawState>((ref) {
  return WithdrawController();
});

class WithdrawController extends StateNotifier<WithdrawState> {
  WithdrawController({WithdrawState? initialState})
      : super(initialState ?? _initialState);

  static const PayoutMethod _defaultMethod = PayoutMethod(
    id: 'pay_01',
    type: PayoutMethodType.bankAccount,
    holderName: 'Alex Johnson',
    accountNumber: '98765432104521',
    ifscCode: 'HDFC0001234',
    bankName: 'HDFC Bank',
    isDefault: true,
  );

  static const WithdrawState _initialState = WithdrawState(
    payoutMethods: [_defaultMethod],
    selectedPayoutMethod: _defaultMethod,
  );

  /// Adds a new bank account payout method
  void addBankPayoutMethod({
    required String holderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
  }) {
    final newMethod = PayoutMethod(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      type: PayoutMethodType.bankAccount,
      holderName: holderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      bankName: bankName,
      isDefault: true,
    );

    final updatedList = [
      newMethod,
      ...state.payoutMethods.map((m) => m.copyWith(isDefault: false)),
    ];

    state = state.copyWith(
      payoutMethods: updatedList,
      selectedPayoutMethod: newMethod,
    );
  }

  /// Adds a new Paytm payout method
  void addPaytmPayoutMethod({
    required String holderName,
    required String paytmNumber,
  }) {
    final newMethod = PayoutMethod(
      id: 'paytm_${DateTime.now().millisecondsSinceEpoch}',
      type: PayoutMethodType.paytm,
      holderName: holderName,
      paytmNumber: paytmNumber,
      isDefault: true,
    );

    final updatedList = [
      newMethod,
      ...state.payoutMethods.map((m) => m.copyWith(isDefault: false)),
    ];

    state = state.copyWith(
      payoutMethods: updatedList,
      selectedPayoutMethod: newMethod,
    );
  }

  /// Backward-compatible alias for adding a bank payout method
  void addPayoutMethod({
    required String holderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
  }) {
    addBankPayoutMethod(
      holderName: holderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      bankName: bankName,
    );
  }

  /// Removes a payout method by id
  void removePayoutMethod(String id) {
    final updatedList = state.payoutMethods.where((m) => m.id != id).toList();
    PayoutMethod? newSelected = state.selectedPayoutMethod;
    if (state.selectedPayoutMethod?.id == id) {
      newSelected = updatedList.isNotEmpty ? updatedList.first : null;
    }
    state = state.copyWith(
      payoutMethods: updatedList,
      selectedPayoutMethod: newSelected,
    );
  }

  /// Sets a method as default
  void setAsDefault(String id) {
    final updatedList = state.payoutMethods.map((m) {
      return m.copyWith(isDefault: m.id == id);
    }).toList();

    final selected = updatedList.firstWhere(
      (m) => m.id == id,
      orElse: () => updatedList.first,
    );

    state = state.copyWith(
      payoutMethods: updatedList,
      selectedPayoutMethod: selected,
    );
  }

  /// Selects active payout method
  void selectPayoutMethod(PayoutMethod method) {
    state = state.copyWith(selectedPayoutMethod: method);
  }

  /// Simulates withdrawal request submission
  Future<String?> submitWithdrawal(double amount) async {
    state = state.copyWith(isSubmitting: true);

    await Future.delayed(const Duration(milliseconds: 1000));

    final refId = 'WDR-${100000 + Random().nextInt(899999)}';

    state = state.copyWith(
      isSubmitting: false,
      lastReferenceId: refId,
    );

    return refId;
  }
}
