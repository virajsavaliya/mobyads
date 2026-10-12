// PLACEHOLDER TEXT — LEGAL REVIEW REQUIRED
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/legal_doc_screen.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const _sections = [
    LegalSection(
      '1. Eligibility & User Account',
      'By downloading and accessing MobyAds, you represent that you are at least 18 years of age (or have explicit parental consent) and reside in a jurisdiction where promotional skill-based news quizzes are legally permissible. Each individual user is permitted to hold exactly ONE registered account. Maintaining duplicate accounts or using simulated identities is strictly prohibited.',
    ),
    LegalSection(
      '2. Quiz Rules & Reward Integrity',
      'MobyAds provides news-based multiple choice questions curated from verified news sources. Users receive coin/cash earnings upon completing quiz sessions and viewing corresponding sponsor messages. Attempting to bypass question timers, script automated answers, or force-skip milestone video advertisements is a direct breach of service and invalidates accumulated earnings.',
    ),
    LegalSection(
      '3. Wallet & Withdrawal Thresholds',
      'Coins accumulated in your MobyAds wallet convert at the stated rate (e.g., 100 Coins = ₹1.00 INR). The minimum allowable payout threshold is ₹50.00. Payouts are executed via standard bank transfers and typically clear within 24 to 48 business hours, subject to recipient bank verification.',
    ),
    LegalSection(
      '4. Anti-Fraud & Prohibited Conduct',
      'The following activities result in immediate account termination and forfeiture of all balances:\n• Use of virtual private networks (VPNs), proxies, or IP spoofing.\n• Running MobyAds on device emulators or rooted/jailbroken devices.\n• Automated clickers, botting scripts, or network manipulation.\n• Referral manipulation or coordinated multi-account rings.',
    ),
    LegalSection(
      '5. Account Suspension & Termination',
      'MobyAds reserves the right to suspend or permanently terminate any user account found in violation of these Terms without prior notice. Disputed decisions may be submitted to our compliance review team within 14 days of account notice.',
    ),
    LegalSection(
      '6. Limitation of Liability',
      'MobyAds is provided on an "as is" and "as available" basis. We are not liable for third-party banking delays, carrier connectivity outages, or intermittent sponsor ad inventory shortages.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: LegalDocScreen(
          title: 'Terms & Conditions',
          banner: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.gavel_rounded, color: Colors.amber.shade900, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please read these terms carefully before participating in daily quiz reward sessions.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          sections: _sections,
        ),
      ),
    );
  }
}
