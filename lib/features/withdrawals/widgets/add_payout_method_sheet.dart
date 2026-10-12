import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/withdraw_controller.dart';
import '../models/payout_method_model.dart';

void showAddPayoutMethodSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AddPayoutMethodSheetContent(parentContext: context),
  );
}

class _AddPayoutMethodSheetContent extends ConsumerStatefulWidget {
  final BuildContext parentContext;

  const _AddPayoutMethodSheetContent({required this.parentContext});

  @override
  ConsumerState<_AddPayoutMethodSheetContent> createState() =>
      _AddPayoutMethodSheetContentState();
}

class _AddPayoutMethodSheetContentState
    extends ConsumerState<_AddPayoutMethodSheetContent> {
  PayoutMethodType _selectedType = PayoutMethodType.bankAccount;

  final _sheetFormKey = GlobalKey<FormState>();

  // Bank Account Controllers
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController(text: 'State Bank of India');
  final _accController = TextEditingController();
  final _confirmAccController = TextEditingController();
  final _ifscController = TextEditingController();

  // Paytm Controllers
  final _paytmNameController = TextEditingController();
  final _paytmNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _accController.dispose();
    _confirmAccController.dispose();
    _ifscController.dispose();
    _paytmNameController.dispose();
    _paytmNumberController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_sheetFormKey.currentState!.validate()) return;

    if (_selectedType == PayoutMethodType.bankAccount) {
      ref.read(withdrawControllerProvider.notifier).addBankPayoutMethod(
            holderName: _nameController.text.trim(),
            accountNumber: _accController.text.trim(),
            ifscCode: _ifscController.text.trim().toUpperCase(),
            bankName: _bankNameController.text.trim(),
          );
      Navigator.pop(context);
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(
          content: Text('Bank account added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ref.read(withdrawControllerProvider.notifier).addPaytmPayoutMethod(
            holderName: _paytmNameController.text.trim(),
            paytmNumber: _paytmNumberController.text.trim(),
          );
      Navigator.pop(context);
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(
          content: Text('Paytm account added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.m,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _sheetFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Payout Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.s),

              // 1. Two-option Type Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        type: PayoutMethodType.bankAccount,
                        title: 'Bank Account',
                        icon: Icons.account_balance_rounded,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildTypeOption(
                        type: PayoutMethodType.paytm,
                        title: 'Paytm',
                        icon: Icons.account_balance_wallet_rounded,
                        activeColor: const Color(0xFF3F3F46),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // 2. Dynamic Form Fields Based on Selected Type
              if (_selectedType == PayoutMethodType.bankAccount) ...[
                // Account Holder Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                    hintText: 'As per bank records',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: AppSpacing.m),

                // Bank Name
                TextFormField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    hintText: 'e.g. HDFC Bank, SBI, ICICI',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Please enter bank name' : null,
                ),
                const SizedBox(height: AppSpacing.m),

                // Account Number
                TextFormField(
                  controller: _accController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bank Account Number',
                  ),
                  validator: (v) =>
                      v == null || v.trim().length < 8 ? 'Enter valid account number' : null,
                ),
                const SizedBox(height: AppSpacing.m),

                // Confirm Account Number
                TextFormField(
                  controller: _confirmAccController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Account Number',
                  ),
                  validator: (v) {
                    if (v != _accController.text) {
                      return 'Account numbers do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.m),

                // IFSC Code
                TextFormField(
                  controller: _ifscController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'IFSC / Routing Code',
                    hintText: 'e.g. SBIN0001234',
                  ),
                  validator: (v) =>
                      v == null || v.trim().length < 5 ? 'Enter valid IFSC code' : null,
                ),
              ] else ...[
                // Shorter Paytm Form
                // Account Holder Name
                TextFormField(
                  controller: _paytmNameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                    hintText: 'As registered on Paytm',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: AppSpacing.m),

                // Paytm-linked Mobile Number
                TextFormField(
                  controller: _paytmNumberController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Paytm Mobile Number',
                    hintText: '10-digit mobile number',
                    prefixText: '+91 ',
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter Paytm mobile number';
                    }
                    final trimmed = v.trim();
                    if (trimmed.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Payouts will be sent directly to your Paytm wallet/UPI linked to this number.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.l),

              // Save Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == PayoutMethodType.paytm
                      ? const Color(0xFF3F3F46)
                      : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedType == PayoutMethodType.bankAccount
                      ? 'Save Bank Account'
                      : 'Save Paytm Account',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required PayoutMethodType type,
    required String title,
    required IconData icon,
    Color activeColor = AppColors.primary,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
