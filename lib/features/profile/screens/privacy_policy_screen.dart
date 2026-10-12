// PLACEHOLDER TEXT — LEGAL REVIEW REQUIRED
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../widgets/legal_doc_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    LegalSection(
      '1. Information We Collect',
      'When you register and engage with MobyAds, we collect personal information you provide voluntarily (such as full name, email address, phone number, and date of birth). Additionally, to process reward payouts, we collect necessary banking metadata (e.g., masked bank account number, account holder name, and IFSC/routing codes).\n\nWe also collect limited device telemetry (such as OS version, device architecture, and unique advertising IDs) strictly for anti-fraud detection and session integrity.',
    ),
    LegalSection(
      '2. How We Use Your Data',
      'We utilize your data to:\n• Authenticate and secure your account against unauthorized access.\n• Verify eligibility for daily quiz sessions and sponsor rewards.\n• Process and disburse electronic cash withdrawals via partner banking gateways.\n• Prevent fraudulent botting, emulator exploitation, and referral abuse.\n• Communicate essential transactional updates and security alerts.',
    ),
    LegalSection(
      '3. Ad Telemetry & Tracking',
      'MobyAds delivers sponsored video and photo advertisements in exchange for quiz reward credits. We do not sell your personally identifiable contact information to advertising networks. Advertisers receive only aggregate, anonymized impressions and completion telemetry to confirm ethical campaign reach.',
    ),
    LegalSection(
      '4. Security & Data Protection',
      'All sensitive information, including payout destinations and authentication tokens, is encrypted in transit using industry-standard TLS 1.3 encryption and stored securely. We maintain rigorous physical and electronic safeguards to defend against data breaches and unauthorized disclosure.',
    ),
    LegalSection(
      '5. Your Rights & Data Deletion',
      'You retain the right to inspect, edit, or request complete deletion of your account and personal data at any time. To request account deletion, you may submit a request through the Help & Support section or by contacting our Data Protection Officer.',
    ),
    LegalSection(
      '6. Contact & Inquiries',
      'If you have questions regarding this Privacy Policy, please reach out to:\n\nMobyAds Privacy Team\nEmail: privacy@mobyads.com\nAddress: 500 Cyber City Boulevard, Suite 400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
          title: 'Privacy Policy',
          banner: Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Last updated: August 2026 • Effective for all active MobyAds accounts.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
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
