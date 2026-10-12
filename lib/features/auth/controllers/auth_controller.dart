import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../models/user_model.dart';
import '../models/auth_state.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthController(secureStorage);
});

class AuthController extends StateNotifier<AuthState> {
  final SecureStorageService _secureStorage;

  AuthController(this._secureStorage) : super(const AuthState());

  /// Checks whether user is already logged in from local storage
  Future<bool> checkAuthStatus() async {
    try {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        // Mock active user session
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: const UserModel(
            id: 'usr_demo_101',
            email: 'demo@mobyads.com',
            name: 'Demo Earner',
            phone: '+91 9876543210',
            coinBalance: 0,
          ),
        );
        return true;
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return false;
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Mock login that saves a dummy token and updates state
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 900));

    try {
      const dummyToken = 'mock_jwt_token_mobyads_sample';
      await _secureStorage.saveToken(dummyToken);

      final user = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@').first,
        coinBalance: 0,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to sign in. Please try again.',
      );
      return false;
    }
  }

  /// Mock Google Sign-In
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    await Future.delayed(const Duration(milliseconds: 900));

    try {
      const dummyToken = 'mock_google_token_sample';
      await _secureStorage.saveToken(dummyToken);

      const user = UserModel(
        id: 'usr_google_sample',
        email: 'google.user@gmail.com',
        name: 'Google User',
        coinBalance: 0,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google Sign-In failed. Please try again.',
      );
      return false;
    }
  }

  /// Mock Registration
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String country,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      const dummyToken = 'mock_registered_jwt_token';
      await _secureStorage.saveToken(dummyToken);

      final user = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
        coinBalance: 0,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  /// Updates user profile in-memory
  void updateProfile({
    required String name,
    required String email,
    String? phone,
    String? dateOfBirth,
    String? country,
    String? avatarUrl,
  }) {
    final currentUser = state.user ?? const UserModel(
      id: 'usr_demo_101',
      email: 'alex.johnson@example.com',
      name: 'Alex Johnson',
    );
    final updatedUser = currentUser.copyWith(
      name: name,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      country: country,
      avatarUrl: avatarUrl,
    );
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: updatedUser,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _secureStorage.clearAuthTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Account deletion: wipes local session + device data, signs out.
  /// Server-side erasure is handled by the backend on next sync.
  Future<void> deleteAccount() async {
    await _secureStorage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
