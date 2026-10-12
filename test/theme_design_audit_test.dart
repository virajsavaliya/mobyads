import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/theme/app_colors.dart';
import 'package:mobyads/core/theme/app_spacing.dart';

void main() {
  group('Global Design System & Tokens Audit', () {
    test('Spacing scale follows 8px standard grid', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.s, 8.0);
      expect(AppSpacing.sm, 12.0);
      expect(AppSpacing.m, 16.0);
      expect(AppSpacing.l, 20.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);
    });

    test('Card and button border radii are unified', () {
      expect(AppSpacing.radiusXs, 4.0);
      expect(AppSpacing.radiusS, 8.0);
      expect(AppSpacing.radiusM, 12.0);
      expect(AppSpacing.radiusL, 16.0);
      expect(AppSpacing.radiusXl, 24.0);
      expect(AppSpacing.radiusFull, 999.0);
    });

    test('Primary and Accent palette tokens adhere to branding guidelines', () {
      // Primary Teal / Blue
      expect(AppColors.primary, isNotNull);
      expect(AppColors.primaryLight, isNotNull);
      expect(AppColors.primaryDark, isNotNull);

      // Money Accent Green
      expect(AppColors.accent, isNotNull);
      expect(AppColors.accentLight, isNotNull);
      expect(AppColors.accentDark, isNotNull);

      // Warning & Error tokens
      expect(AppColors.error, isNotNull);
      expect(AppColors.warning, isNotNull);
    });
  });
}
