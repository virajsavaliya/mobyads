import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/controllers/auth_controller.dart';

/// Delete account (Operate): one clear consequence statement + confirm.
/// Irreversible; local session and device data are wiped on delete.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  /// Test seam: called instead of router navigation after deletion.
  final VoidCallback? onDeleted;

  const DeleteAccountScreen({super.key, this.onDeleted});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _acknowledged = false;
  bool _deleting = false;

  Future<void> _delete() async {
    if (!_acknowledged || _deleting) return;
    setState(() => _deleting = true);
    await ref.read(authControllerProvider.notifier).deleteAccount();
    if (!mounted) return;
    if (widget.onDeleted != null) {
      widget.onDeleted!();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delete Account'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'This cannot be undone',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.s),
                    Text(
                      'Deleting your account permanently removes your profile, wallet history, coupons, and payout methods from this device. Any pending withdrawals under review are cancelled.\n\nData handling follows the Privacy Policy retention rules for fraud prevention.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              GestureDetector(
                onTap: () =>
                    setState(() => _acknowledged = !_acknowledged),
                child: Row(
                  children: [
                    Checkbox(
                      value: _acknowledged,
                      onChanged: (v) =>
                          setState(() => _acknowledged = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I understand my account and data will be permanently deleted.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              ElevatedButton(
                onPressed: _acknowledged && !_deleting ? _delete : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, AppSpacing.buttonHeight),
                ),
                child: Text(
                  _deleting ? 'Deleting…' : 'Delete My Account',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
