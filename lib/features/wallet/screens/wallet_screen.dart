import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/config/server_config_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../widgets/app_empty_state.dart';
import '../controllers/wallet_controller.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_detail_sheet.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final walletState = ref.watch(walletControllerProvider);
    final walletNotifier = ref.read(walletControllerProvider.notifier);
    final groupedTransactions = walletState.groupedTransactions;
    final minWithdrawal = ref.watch(serverConfigProvider).minWithdrawal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Wallet & Payout Info',
            onPressed: () {
              _showWalletInfoDialog(context, minWithdrawal);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => walletNotifier.refresh(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Detailed Balance Summary Card
              _buildDetailedBalanceCard(theme, walletState),
              const SizedBox(height: AppSpacing.m),

              // 2. Full-Width Prominent "Withdraw Funds" Button
              ElevatedButton.icon(
                onPressed: () => context.push('/withdraw'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentDark,
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, AppSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.accent.withValues(alpha: 0.35),
                ),
                icon: const Icon(Icons.arrow_circle_up_rounded, size: 22),
                label: const Text(
                  'Withdraw Funds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // 3. Transaction History Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${walletState.transactions.length} items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),

              // 4. Date-Grouped Transaction List
              if (groupedTransactions.isEmpty)
                _buildEmptyState()
              else
                ...groupedTransactions.entries.map((entry) {
                  return _buildDateGroup(theme, entry.key, entry.value);
                }),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Detailed Balance Card
  Widget _buildDetailedBalanceCard(ThemeData theme, WalletState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF18181B), // Zinc 900
            Color(0xFF000000), // Black
            Color(0xFF27272A), // Zinc 800
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18181B).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient decorative pattern
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Label + Coin Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AVAILABLE BALANCE',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 13,
                            color: AppColors.accentGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(state.availableBalance * 100).toInt()} Coins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),

                // Large Main Balance
                Text(
                  Formatters.formatCurrency(state.availableBalance),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // 3-Metric Stats Row Sub-card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Pending
                      Expanded(
                        child: _buildSubMetric(
                          title: 'Pending',
                          value: Formatters.formatCurrency(state.pendingBalance),
                          valueColor: AppColors.accentGold,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),

                      // Total Earned
                      Expanded(
                        child: _buildSubMetric(
                          title: 'Total Earned',
                          value: Formatters.formatCurrency(state.totalEarned),
                          valueColor: AppColors.accentLight,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),

                      // Withdrawn
                      Expanded(
                        child: _buildSubMetric(
                          title: 'Withdrawn',
                          value: Formatters.formatCurrency(state.totalWithdrawn),
                          valueColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetric({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// 4. Date-Grouped Transaction List
  Widget _buildDateGroup(
    ThemeData theme,
    String groupTitle,
    List<TransactionModel> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.m,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            groupTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 56,
              color: AppColors.divider,
            ),
            itemBuilder: (context, index) {
              final tx = items[index];
              return _TransactionTile(transaction: tx);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No transactions yet',
        description: 'Complete daily quizzes and tasks to start earning cash rewards.',
      ),
    );
  }

  void _showWalletInfoDialog(BuildContext context, double minWithdrawal) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Wallet Info'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• 100 Coins = ₹1.00 INR\n'
              '• Available Balance: Ready for immediate withdrawal via UPI, Paytm, or Bank Transfer.\n'
              '• Pending Balance: Verified offers undergoing a standard 24h fraud check.\n'
              '• Minimum Withdrawal: ${Formatters.formatCurrency(minWithdrawal)}.',
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Transaction Row Item Tile
class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final timeFormat = DateFormat('hh:mm a');
    final formattedTime = timeFormat.format(transaction.timestamp);

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => TransactionDetailSheet(transaction: transaction),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s + 2,
        ),
        child: Row(
        children: [
          // Directional Icon Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCredit ? AppColors.accentLight : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                isCredit
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                size: 20,
                color: isCredit ? AppColors.accentDark : Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),

          // Title & Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Amount & Status Chip
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${Formatters.formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.accentDark : Colors.red.shade700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 3),
              _buildStatusChip(transaction.status),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case TransactionStatus.available:
        bg = AppColors.accentLight;
        text = AppColors.accentDark;
        label = 'Available';
        break;
      case TransactionStatus.pending:
        bg = Colors.amber.shade50;
        text = Colors.amber.shade900;
        label = 'Pending';
        break;
      case TransactionStatus.withdrawn:
        bg = Colors.blue.shade50;
        text = Colors.blue.shade800;
        label = 'Withdrawn';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}
