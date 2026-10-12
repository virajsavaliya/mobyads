import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum AdaptiveButtonStyle {
  prominentGlass,
  plain,
}

/// Adaptive Nav Item that renders iOS Cupertino SF Symbols with Prominent Glass styling on iOS
/// and Material icons with animated pill highlight on Android.
class AdaptiveNavButton extends StatelessWidget {
  final int index;
  final bool isSelected;
  final String label;
  final IconData materialIcon;
  final IconData materialActiveIcon;
  final IconData cupertinoIcon;
  final IconData cupertinoActiveIcon;
  final VoidCallback onTap;

  const AdaptiveNavButton({
    super.key,
    required this.index,
    required this.isSelected,
    required this.label,
    required this.materialIcon,
    required this.materialActiveIcon,
    required this.cupertinoIcon,
    required this.cupertinoActiveIcon,
    required this.onTap,
  });

  bool get _isIOS => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    const inactiveColor = Color(0xFF475569); // Solid dark-grey/slate

    final icon = _isIOS
        ? (isSelected ? cupertinoActiveIcon : cupertinoIcon)
        : (isSelected ? materialActiveIcon : materialIcon);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16 : 8,
              vertical: isSelected ? 6 : 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
              border: isSelected
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1.2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
