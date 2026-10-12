import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/server_config_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/server_contract.dart';
import '../../../widgets/loading_button.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../controllers/withdraw_controller.dart';
import '../models/payout_method_model.dart';
import '../widgets/add_payout_method_sheet.dart';
import '../widgets/withdrawal_status_stepper.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _amountController = TextEditingController();
  String? _errorText;
  bool _isValid = false;
  bool _showBreakdownDetails = false;

  double get _minWithdrawal =>
      ref.read(serverConfigProvider).minWithdrawal;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateAmount);
    Future.microtask(() async {
      await ref.read(serverConfigProvider.notifier).load();
      if (mounted) _validateAmount();
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateAmount);
    _amountController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorText = null;
        _isValid = false;
      });
      return;
    }

    final amount = double.tryParse(text);
    final availableBalance =
        ref.read(walletControllerProvider).availableBalance;

    if (amount == null) {
      setState(() {
        _errorText = 'Please enter a valid numeric amount';
        _isValid = false;
      });
    } else if (amount < _minWithdrawal) {
      setState(() {
        _errorText =
            'Minimum withdrawal amount is ${Formatters.formatCurrency(_minWithdrawal)}';
        _isValid = false;
      });
    } else if (amount > availableBalance) {
      setState(() {
        _errorText =
            'Amount exceeds available balance (${Formatters.formatCurrency(availableBalance)})';
        _isValid = false;
      });
    } else {
      setState(() {
        _errorText = null;
        _isValid = true;
      });
    }
  }

  void _setWithdrawAll() {
    final availableBalance =
        ref.read(walletControllerProvider).availableBalance;
    _amountController.text = availableBalance.toStringAsFixed(2);
  }

  void _openAddPayoutMethodSheet() {
    showAddPayoutMethodSheet(context, ref);
  }

  void _showSuccessDialog(String refId, double amount) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.s),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 48,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Text(
                'Withdrawal Requested!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${Formatters.formatCurrency(amount)} payout is being processed',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentDark,
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // Lifecycle stepper: requested → processing (paid on backend webhook)
              const WithdrawalStatusStepper(
                status: WithdrawalServerStatus.processing,
              ),
              const SizedBox(height: AppSpacing.l),

              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reference ID',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          refId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Time',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          '24 – 48 Hours',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  context.go('/wallet');
                },
                child: const Text('Done'),
              ),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleWithdrawSubmit() async {
    FocusScope.of(context).unfocus();
    // Harden: block duplicate submits while a request is in flight.
    if (!_isValid) return;
    if (ref.read(withdrawControllerProvider).isSubmitting) return;

    final amount = double.parse(_amountController.text.trim());
    final refId = await ref
        .read(withdrawControllerProvider.notifier)
        .submitWithdrawal(amount);

    if (mounted && refId != null) {
      _showSuccessDialog(refId, amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletState = ref.watch(walletControllerProvider);
    final withdrawState = ref.watch(withdrawControllerProvider);
    final serverConfig = ref.watch(serverConfigProvider);
    final minWithdrawal = serverConfig.minWithdrawal;
    final availableBalance = walletState.availableBalance;
    final selectedMethod = withdrawState.selectedPayoutMethod;
    final isSubmitting = withdrawState.isSubmitting;

    final double enteredAmount =
        double.tryParse(_amountController.text.trim()) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdraw'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Available Balance Pill Header
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 16,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Available Balance: ${Formatters.formatCurrency(availableBalance)}',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // 2. Amount Input Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _errorText != null
                        ? AppColors.error
                        : (_isValid ? AppColors.accent : AppColors.divider),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ENTER AMOUNT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: _setWithdrawAll,
                          child: const Text(
                            'Withdraw All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Large Numeric Input Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_isValid)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.accent,
                            size: 24,
                          ),
                      ],
                    ),
                    const Divider(),

                    // Min Note & Error text
                    if (_errorText != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 14,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Minimum withdrawal: ${Formatters.formatCurrency(minWithdrawal)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // 3. Payout Method Section
              Text(
                'Payout Destination',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s),

              if (selectedMethod != null)
                _buildSelectedPayoutCard(selectedMethod)
              else
                _buildEmptyPayoutCard(),

              const SizedBox(height: AppSpacing.l),

              // 4. Summary Breakdown Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Withdrawal Amount',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(enteredAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Distilled: fee + ETA revealed on tap
                    if (_showBreakdownDetails) ...[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Processing Fee',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '₹0.00 (Free)',
                            style: TextStyle(
                              color: AppColors.accentDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Time',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '24 – 48 Hours',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    GestureDetector(
                      onTap: () => setState(() {
                        _showBreakdownDetails = !_showBreakdownDetails;
                      }),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showBreakdownDetails
                                ? 'Hide details'
                                : 'Fee & timing details',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            _showBreakdownDetails
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "You'll Receive",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(enteredAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 5. Request Withdrawal Button
              LoadingButton(
                label: 'Request Withdrawal',
                isLoading: isSubmitting,
                onPressed:
                    (_isValid && withdrawState.hasPayoutMethod && !isSubmitting)
                        ? _handleWithdrawSubmit
                        : null,
                backgroundColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPayoutCard(PayoutMethod method) {
    final isPaytm = method.isPaytm;
    final iconColor = isPaytm ? const Color(0xFF3F3F46) : AppColors.primary;
    final iconBg = isPaytm ? const Color(0xFFF4F4F5) : AppColors.primaryLight;
    final iconData =
        isPaytm ? Icons.account_balance_wallet_rounded : Icons.account_balance_rounded;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaytm
              ? const Color(0xFF3F3F46).withValues(alpha: 0.35)
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isPaytm) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'WALLET',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3F3F46),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  method.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openAddPayoutMethodSheet,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPayoutCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 36,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.s),
          const Text(
            'No payout method added',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Payout Method'),
            onPressed: _openAddPayoutMethodSheet,
          ),
        ],
      ),
    );
  }
}
