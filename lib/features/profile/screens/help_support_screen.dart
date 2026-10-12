import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class _FaqItem {
  final String question;
  final String answer;
  final String category;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<_FaqItem> _allFaqs = [
    _FaqItem(
      question: 'How do I earn money on MobyAds?',
      answer:
          'You earn money by completing the daily news quiz (10 multiple choice questions) and engaging with sponsor messages. Coins accumulate in your wallet and can be directly withdrawn to your bank account at 100 Coins = ₹1.00 INR.',
      category: 'Earnings',
    ),
    _FaqItem(
      question: 'Why was my quiz reward not credited immediately?',
      answer:
          'Rewards are credited as soon as all 10 questions and both milestone sponsor videos (Question 5 and Question 10) are successfully completed. If your connection dropped during the session, please check your wallet transaction history after 5 minutes.',
      category: 'Quiz',
    ),
    _FaqItem(
      question: 'How long do bank withdrawals take?',
      answer:
          'Electronic bank transfers are typically processed within 24 to 48 business hours. You will receive a notification and a unique Reference ID (e.g., WDR-123456) to track the payout status.',
      category: 'Payouts',
    ),
    _FaqItem(
      question: 'What is the minimum withdrawal amount?',
      answer:
          'The minimum withdrawal threshold is ₹50.00. You can accumulate earnings across multiple daily quiz sessions before initiating a transfer.',
      category: 'Payouts',
    ),
    _FaqItem(
      question: 'Why can’t I exit or skip during milestone video ads?',
      answer:
          'Sponsors fund your cash rewards by presenting high-value video messages at Questions 5 and 10. Watching these milestone videos ensures our advertisers can continue offering free daily cash prizes to all learners.',
      category: 'Quiz',
    ),
    _FaqItem(
      question: 'How do I add or update my bank account?',
      answer:
          'Go to Profile > Payout Methods, tap "+ Add New Method", and input your bank name, account holder name, account number, and IFSC code. You can save multiple bank accounts and switch your default destination at any time.',
      category: 'Account',
    ),
    _FaqItem(
      question: 'Can I use a VPN or multiple accounts?',
      answer:
          'No. To maintain fairness and prevent ad fraud, MobyAds strictly prohibits VPNs, emulators, automated bot scripts, and multiple accounts per individual. Violations result in immediate account suspension.',
      category: 'Account',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchSupportEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@mobyads.com',
      queryParameters: {
        'subject': 'Support Request - MobyAds App',
        'body': 'Hi MobyAds Support,\n\nI need help with:\n\nDevice: iOS / Flutter\nAccount Email: alex.johnson@example.com',
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Support Email: support@mobyads.com'),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support Email: support@mobyads.com'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _allFaqs.where((faq) {
      if (_searchQuery.isEmpty) return true;
      return faq.question.toLowerCase().contains(_searchQuery) ||
          faq.answer.toLowerCase().contains(_searchQuery) ||
          faq.category.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
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
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search FAQ & questions...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // 2. FAQ Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FREQUENTLY ASKED QUESTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    '${filteredFaqs.length} FAQs',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),

              // 3. FAQ List
              if (filteredFaqs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: AppSpacing.m),
                      const Text(
                        'No matching questions found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try searching for different keywords or reach out below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
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
                      itemCount: filteredFaqs.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.divider,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredFaqs[index];
                        return Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.m,
                              vertical: 2,
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              AppSpacing.m,
                              0,
                              AppSpacing.m,
                              AppSpacing.m,
                            ),
                            title: Text(
                              item.question,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            children: [
                              Text(
                                item.answer,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.l),

              // 4. "Still Need Help?" Support Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E7490), Color(0xFF155E75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    const Text(
                      'Still need help?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Our dedicated support team typically responds within 4 hours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: const Text('Contact Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _launchSupportEmail,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
