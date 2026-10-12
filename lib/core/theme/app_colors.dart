import 'package:flutter/material.dart';

/// App Color Palette
/// Trustworthy Blue/Teal primary with Money/Earnings Accent Green
class AppColors {
  AppColors._();

  // Primary Palette - Trustworthy Deep Blue/Teal
  static const Color primary = Color(0xFF0E7490);       // Cyan-700 / Ocean Teal
  static const Color primaryDark = Color(0xFF155E75);   // Cyan-800
  static const Color primaryLight = Color(0xFFE0F2FE);  // Sky-100
  static const Color primaryContainer = Color(0xFFBAE6FD);

  // Accent Palette - Money / Earnings Green
  static const Color accent = Color(0xFF10B981);        // Emerald-500
  static const Color accentDark = Color(0xFF059669);    // Emerald-600
  static const Color accentLight = Color(0xFFD1FAE5);   // Emerald-100
  static const Color accentGold = Color(0xFFF59E0B);    // Coin Gold / Amber

  // Neutral / Background Colors (Light Mode)
  static const Color background = Color(0xFFF8FAFC);    // Slate-50
  static const Color surface = Color(0xFFFFFFFF);       // White
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);       // Slate-200
  static const Color border = Color(0xFFCBD5E1);        // Slate-300

  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF0F172A);   // Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textMuted = Color(0xFF94A3B8);     // Slate-400
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
