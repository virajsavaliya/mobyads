import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/config/server_config_provider.dart';
import 'package:mobyads/core/network/api_client.dart';
import 'package:mobyads/core/storage/secure_storage_service.dart';
import 'package:mobyads/features/withdrawals/screens/withdraw_screen.dart';

class _FakeStorage extends SecureStorageService {
  @override
  Future<String?> getToken() async => null;
}

class _OfflineApiClient extends ApiClient {
  _OfflineApiClient() : super(dio: Dio(), secureStorage: _FakeStorage());

  @override
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    throw DioException(requestOptions: RequestOptions(path: path));
  }
}

void main() {
  testWidgets('Withdraw distill: fee & ETA hidden until tapped', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(_OfflineApiClient()),
        ],
        child: const MaterialApp(
          home: WithdrawScreen(),
        ),
      ),
    );

    // Core confirm focus visible; details collapsed
    expect(find.text('Request Withdrawal'), findsOneWidget);
    expect(find.text("You'll Receive"), findsOneWidget);
    expect(find.text('Fee & timing details'), findsOneWidget);
    expect(find.text('Estimated Time'), findsNothing);

    // Expand reveals fee + ETA
    await tester.tap(find.text('Fee & timing details'));
    await tester.pumpAndSettle();
    expect(find.text('Estimated Time'), findsOneWidget);
    expect(find.text('24 – 48 Hours'), findsOneWidget);
    expect(find.text('Hide details'), findsOneWidget);
  });
}
