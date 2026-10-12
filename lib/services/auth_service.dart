import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

/// Authentication Service
class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthService({
    ApiClient? apiClient,
    SecureStorageService? secureStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _secureStorage = secureStorage ?? SecureStorageService();

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserModel?> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200 && response.data != null) {
      final token = response.data['token'] as String?;
      if (token != null) {
        await _secureStorage.saveToken(token);
      }
      return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.clearAuthTokens();
  }
}
