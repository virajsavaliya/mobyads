import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/config/server_config.dart';
import 'package:mobyads/core/config/server_config_provider.dart';
import 'package:mobyads/core/network/api_client.dart';
import 'package:mobyads/core/network/api_endpoints.dart';
import 'package:mobyads/core/storage/secure_storage_service.dart';

class FakeStorage extends SecureStorageService {
  @override
  Future<String?> getToken() async => null;
}

class FakeApiClient extends ApiClient {
  final Map<String, dynamic>? data;
  final bool fail;
  FakeApiClient({this.data, this.fail = false})
      : super(dio: Dio(), secureStorage: FakeStorage());

  @override
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    assert(path == ApiEndpoints.publicConfig);
    if (fail) {
      throw DioException(requestOptions: RequestOptions(path: path));
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data as T?,
    );
  }
}

void main() {
  test('ServerConfig defaults match backend seed', () {
    const c = ServerConfig();
    expect(c.minWithdrawal, 50.0);
    expect(c.dailyLimit, 1000.0);
    expect(c.taskCooldownMinutes, 60);
    expect(c.mcqCount, 10);
    expect(c.rewardMcq, 1.50);
    expect(c.rewardAd, 2.00);
  });

  test('ServerConfig parses snake_case + camelCase', () {
    final a = ServerConfig.fromJson({
      'min_withdrawal': 75,
      'daily_limit': 2000,
      'task_cooldown_minutes': 30,
      'mcq_count': 5,
      'reward_mcq': 2.0,
      'reward_ad': 3.0,
      'currency': 'INR',
    });
    expect(a.minWithdrawal, 75.0);
    expect(a.taskCooldownMinutes, 30);

    final b = ServerConfig.fromJson({
      'minWithdrawal': 80,
      'taskCooldownMinutes': 15,
    });
    expect(b.minWithdrawal, 80.0);
    expect(b.taskCooldownMinutes, 15);
  });

  test('load() uses server value, falls back to defaults on error', () async {
    final ok = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(
          FakeApiClient(data: {'min_withdrawal': 99.0})),
    ]);
    await ok.read(serverConfigProvider.notifier).load();
    expect(ok.read(serverConfigProvider).minWithdrawal, 99.0);
    expect(ok.read(serverConfigProvider.notifier).loadedFromServer, true);
    ok.dispose();

    final bad = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(FakeApiClient(fail: true)),
    ]);
    await bad.read(serverConfigProvider.notifier).load();
    expect(bad.read(serverConfigProvider).minWithdrawal, 50.0);
    expect(bad.read(serverConfigProvider.notifier).loadedFromServer, false);
    bad.dispose();
  });
}
