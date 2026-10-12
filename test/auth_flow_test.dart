import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/auth/controllers/auth_controller.dart';
import 'package:mobyads/features/auth/models/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Auth Functional Validation Tests', () {
    test('AuthController manages login state and mock session', () async {
      final container = ProviderContainer();
      final controller = container.read(authControllerProvider.notifier);

      expect(container.read(authControllerProvider).status, AuthStatus.initial);

      // Execute login
      final success = await controller.login(
        email: 'alex@example.com',
        password: 'Password123',
      );

      expect(success, isTrue);
      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
      expect(container.read(authControllerProvider).user?.email, 'alex@example.com');

      // Execute logout
      await controller.logout();
      expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
      expect(container.read(authControllerProvider).user, isNull);
    });

    test('AuthController registration saves new user session', () async {
      final container = ProviderContainer();
      final controller = container.read(authControllerProvider.notifier);

      final registered = await controller.register(
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '9876543210',
        country: 'India',
        password: 'SecurePassword1',
      );

      expect(registered, isTrue);
      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
      expect(container.read(authControllerProvider).user?.name, 'Jane Doe');
    });
  });
}
