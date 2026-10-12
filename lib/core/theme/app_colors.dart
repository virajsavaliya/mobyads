import 'package:flutter/material.dart';

/// App Color Palette
/// Monochrome black & white brand. Semantic status colors are the only
/// exception (success/warning/error/info carry ledger meaning per DESIGN.md).
class AppColors {
  AppColors._();

  // Primary Palette - Black / Zinc
  static const Color primary = Color(0xFF18181B);       // Zinc-900
  static const Color primaryDark = Color(0xFF000000);   // Black
  static const Color primaryLight = Color(0xFFF4F4F5);  // Zinc-100
  static const Color primaryContainer = Color(0xFFE4E4E7);

  // Accent Palette - Monochrome (same ramp; statuses use semantic colors)
  static const Color accent = Color(0xFF18181B);        // Zinc-900
  static const Color accentDark = Color(0xFF000000);    // Black
  static const Color accentLight = Color(0xFFF4F4F5);   // Zinc-100
  static const Color accentGold = Color(0xFF71717A);    // Coin Gray / Zinc-500

  // Neutral / Background Colors (Light Mode)
  static const Color background = Color(0xFFFAFAFA);    // Zinc-50
  static const Color surface = Color(0xFFFFFFFF);      // White
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE4E4E7);       // Zinc-200
  static const Color border = Color(0xFFD4D4D8);        // Zinc-300

  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF09090B);   // Zinc-950
  static const Color textSecondary = Color(0xFF52525B); // Zinc-600
  static const Color textMuted = Color(0xFFA1A1AA);     // Zinc-400
  static const Color textInverse = Color(0xFFFFFFFF);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);       // Green
  static const Color warning = Color(0xFFF59E0B);       // Amber
  static const Color error = Color(0xFFEF4444);         // Red
  static const Color info = Color(0xFF3B82F6);          // Blue

  // Shimmer / Skeletons
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
}
