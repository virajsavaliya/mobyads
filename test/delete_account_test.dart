import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/auth/controllers/auth_controller.dart';
import 'package:mobyads/features/profile/screens/delete_account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Delete screen gates button on acknowledgement', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DeleteAccountScreen()),
      ),
    );

    expect(find.text('This cannot be undone'), findsOneWidget);
    final button = find.text('Delete My Account');
    expect(button, findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.ancestor(
      of: button,
      matching: find.byType(ElevatedButton),
    )).enabled, isFalse);

    // Acknowledge enables deletion
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(find.ancestor(
      of: button,
      matching: find.byType(ElevatedButton),
    )).enabled, isTrue);
  });

  testWidgets('Confirmed deletion wipes session', (tester) async {
    SharedPreferences.setMockInitialValues({});
    var deleted = false;
    final container = ProviderContainer();
    await container.read(authControllerProvider.notifier).login(
          email: 'a@b.c',
          password: 'password123',
        );
    expect(
      container.read(authControllerProvider).status.name,
      'authenticated',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: DeleteAccountScreen(onDeleted: () => deleted = true),
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete My Account'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
    expect(
      container.read(authControllerProvider).status.name,
      'unauthenticated',
    );
    container.dispose();
  });
}
