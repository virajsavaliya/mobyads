import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/server_contract.dart';

/// Withdrawal lifecycle stepper (PDF §16, Operate).
/// PENDING → APPROVED → PROCESSING → PAID, or → FAILED / REJECTED.
/// Shows failure reason + funds-returned message on terminal failure.
class WithdrawalStatusStepper extends StatelessWidget {
  final WithdrawalServerStatus status;
  final String? failureReason;

  const WithdrawalStatusStepper({
    super.key,
    required this.status,
    this.failureReason,
  });

  static const _steps = ['Requested', 'Approved', 'Processing', 'Paid'];

  int get _currentIndex => switch (status) {
        WithdrawalServerStatus.pending => 0,
        WithdrawalServerStatus.approved => 1,
        WithdrawalServerStatus.processing => 2,
        WithdrawalServerStatus.paid => 3,
        WithdrawalServerStatus.failed ||
        WithdrawalServerStatus.rejected =>
          2,
      };

  bool get _isFailed => status == WithdrawalServerStatus.failed ||
      status == WithdrawalServerStatus.rejected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final done = (i ~/ 2) < _currentIndex;
              return Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: done ? AppColors.accent : AppColors.divider,
                ),
              );
            }
            final stepIndex = i ~/ 2;
            final done = stepIndex <= _currentIndex && !_isFailed;
            final failedHere = _isFailed && stepIndex == 2;
            return Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: failedHere
                    ? AppColors.error
                    : done
                        ? AppColors.accent
                        : AppColors.surface,
                border: Border.all(
                  color: failedHere
                      ? AppColors.error
                      : done
                          ? AppColors.accent
                          : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Icon(
                failedHere
                    ? Icons.close_rounded
                    : done
                        ? Icons.check_rounded
                        : null,
                size: 13,
                color: Colors.white,
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < _steps.length; i++)
              Expanded(
                child: Text(
                  _steps[i],
                  textAlign: i == 0
                      ? TextAlign.start
                      : i == _steps.length - 1
                          ? TextAlign.end
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: i <= _currentIndex && !_isFailed
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ),
          ],
        ),
        if (_isFailed) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              '${status == WithdrawalServerStatus.rejected ? 'Rejected' : 'Failed'}${failureReason != null ? ': $failureReason' : ''}. Reserved funds were returned to your available balance.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
