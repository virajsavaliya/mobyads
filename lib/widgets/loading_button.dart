import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Reusable polished button with built-in loading spinner and disabled state
class LoadingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height = AppSpacing.buttonHeight,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(14);
    final effectiveBg = backgroundColor ?? AppColors.primary;
    final effectiveFg = foregroundColor ?? (isOutlined ? effectiveBg : Colors.white);
    final bool canPress = onPressed != null && !isLoading;

    final childWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: canPress ? effectiveFg : AppColors.textMuted),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: canPress ? effectiveFg : AppColors.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: canPress ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveFg,
            side: BorderSide(
              color: canPress ? effectiveBg : AppColors.divider,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
          ),
          child: childWidget,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPress ? effectiveBg : AppColors.border,
          foregroundColor: effectiveFg,
          elevation: canPress ? 2 : 0,
          shadowColor: effectiveBg.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
        ),
        child: childWidget,
      ),
    );
  }
}
