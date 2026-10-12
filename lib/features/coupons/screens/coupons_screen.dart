import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/coupon_controller.dart';
import '../models/coupon_model.dart';

/// Coupons wallet (Operate): Available / Used / Expired tabs.
/// Code hidden until opened; redeem first, terms collapsed.
class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Coupons'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'Used'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _CouponList(status: CouponStatus.available),
          _CouponList(status: CouponStatus.used),
          _CouponList(status: CouponStatus.expired),
        ],
      ),
    );
  }
}

class _CouponList extends ConsumerWidget {
  final CouponStatus status;
  const _CouponList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons =
        ref.watch(couponControllerProvider.notifier).forStatus(status);
    if (coupons.isEmpty) {
      return Center(
        child: Text(
          status == CouponStatus.available
              ? 'No coupons yet — complete tasks to earn some.'
              : 'Nothing here.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: AppSpacing.screenPadding,
      itemCount: coupons.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
      itemBuilder: (context, index) =>
          _CouponCard(coupon: coupons[index]),
    );
  }
}

class _CouponCard extends ConsumerStatefulWidget {
  final Coupon coupon;
  const _CouponCard({required this.coupon});

  @override
  ConsumerState<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends ConsumerState<_CouponCard> {
  bool _revealed = false;
  bool _termsOpen = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.coupon;
    final dateFormat = DateFormat('dd MMM yyyy');
    final dimmed = c.status != CouponStatus.available;

    return Opacity(
      opacity: dimmed ? 0.65 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: AppColors.accentDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (c.expiryDate != null)
                        Text(
                          'Expires ${dateFormat.format(c.expiryDate!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                _StatusChip(status: c.status),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            if (_revealed)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Text(
                        c.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: c.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coupon code copied.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy'),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => _revealed = true),
                  child: const Text('Reveal code'),
                ),
              ),
            if (c.status == CouponStatus.available) ...[
              const SizedBox(height: AppSpacing.s),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final ok = ref
                        .read(couponControllerProvider.notifier)
                        .redeem(c.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Coupon redeemed.'
                            : 'Coupon cannot be redeemed.'),
                        backgroundColor:
                            ok ? AppColors.success : AppColors.error,
                      ),
                    );
                  },
                  child: Text(
                    'Redeem ${Formatters.formatCurrency(c.value)}',
                  ),
                ),
              ),
            ],
            if (c.description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              GestureDetector(
                onTap: () => setState(() => _termsOpen = !_termsOpen),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _termsOpen ? 'Hide terms' : 'Terms',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      _termsOpen
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              if (_termsOpen)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    c.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final CouponStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      CouponStatus.available => ('Available', AppColors.accentLight, AppColors.accentDark),
      CouponStatus.used => ('Used', AppColors.primaryLight, AppColors.primaryDark),
      CouponStatus.expired => ('Expired', const Color(0xFFF1F5F9), AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
