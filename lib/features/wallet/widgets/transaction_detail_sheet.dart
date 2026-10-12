import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/transaction_model.dart';

/// Transaction detail bottom sheet (Operate, plan): source, amount,
/// status with plain-language reason, availableAt; IDs behind Details.
class TransactionDetailSheet extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  State<TransactionDetailSheet> createState() =>
      _TransactionDetailSheetState();
}

String statusReason(TransactionStatus status) => switch (status) {
      TransactionStatus.available =>
        'Ready for withdrawal to your payout method.',
      TransactionStatus.pending =>
        'Undergoing the standard 24h fraud check.',
      TransactionStatus.withdrawn => 'Paid out to your payout method.',
    };

class _TransactionDetailSheetState extends State<TransactionDetailSheet> {
  bool _detailsOpen = false;

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tx.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${tx.isCredit ? '+' : '-'}${Formatters.formatCurrency(tx.amount)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: tx.isCredit
                      ? AppColors.accentDark
                      : Colors.red.shade700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            dateFormat.format(tx.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              statusReason(tx.status),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          GestureDetector(
            onTap: () => setState(() => _detailsOpen = !_detailsOpen),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _detailsOpen ? 'Hide details' : 'Details',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _detailsOpen
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          if (_detailsOpen) ...[
            const SizedBox(height: AppSpacing.xs),
            _DetailRow(label: 'Status', value: tx.status.name),
            _DetailRow(label: 'Type', value: tx.type.name),
            _DetailRow(label: 'Transaction ID', value: tx.id, mono: true),
            if (tx.referenceId != null)
              _DetailRow(
                label: 'Reference',
                value: tx.referenceId!,
                mono: true,
              ),
          ],
          const SizedBox(height: AppSpacing.m),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
