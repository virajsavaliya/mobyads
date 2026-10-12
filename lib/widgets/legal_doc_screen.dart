import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Shared Read-mode legal document scaffold (plan Phase E):
/// readable type, short sections, table of contents with anchor scroll.
/// NOTE: copy is placeholder pending legal review; figures in text are
/// illustrative until business rules freeze (PRODUCT.md).
class LegalDocScreen extends StatefulWidget {
  final String title;
  final Widget banner;
  final List<LegalSection> sections;

  const LegalDocScreen({
    super.key,
    required this.title,
    required this.banner,
    required this.sections,
  });

  @override
  State<LegalDocScreen> createState() => _LegalDocScreenState();
}

class LegalSection {
  final String title;
  final String content;
  const LegalSection(this.title, this.content);
}

class _LegalDocScreenState extends State<LegalDocScreen> {
  final _scrollController = ScrollController();
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.sections.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    final ctx = _keys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.banner,
          const SizedBox(height: AppSpacing.l),
          Text(
            'Contents',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.sections.length, (i) {
              final short = widget.sections[i].title
                  .replaceFirst(RegExp(r'^\d+\.\s*'), '');
              return GestureDetector(
                onTap: () => _jumpTo(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${i + 1}. $short',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.l),
          for (int i = 0; i < widget.sections.length; i++)
            Padding(
              key: _keys[i],
              padding: const EdgeInsets.only(bottom: AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sections[i].title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    widget.sections[i].content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
