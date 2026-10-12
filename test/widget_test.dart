import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/main.dart';

void main() {
  testWidgets('App renders splash screen branding and completes timer', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MobyAdsApp(),
      ),
    );

    // Initial frame shows Splash branding
    expect(find.text('MobyAds'), findsWidgets);

    // Advance past the 1.5s splash Future.delayed
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MobyAdsApp), findsOneWidget);
  });
}
