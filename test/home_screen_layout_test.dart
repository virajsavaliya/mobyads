import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/config/server_config_provider.dart';
import 'package:mobyads/core/network/api_client.dart';
import 'package:mobyads/core/storage/secure_storage_service.dart';
import 'package:mobyads/features/home/screens/home_screen.dart';

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
  testWidgets('HomeScreen distilled layout: balance hero, task, stats, carousel', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(_OfflineApiClient()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // 1. Balance hero present (distilled Home brief)
    expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
    expect(find.text('Withdraw'), findsOneWidget);
    expect(find.textContaining('Pending'), findsOneWidget);

    // 2. Greeting Header exists
    expect(find.textContaining('Hi,'), findsOneWidget);
    expect(find.text('Ready to earn today?'), findsOneWidget);

    // 3. Ad Carousel still present but demoted below money + task
    expect(find.byType(PageView), findsOneWidget);

    // 4. Stat Chips exist
    expect(find.text('Total Earned'), findsOneWidget);
    expect(find.text('Tasks Today'), findsOneWidget);
    expect(find.text('Ads Watched'), findsOneWidget);

    // 5. Today's Task section with server-driven copy + daily-limit hint
    expect(find.text("Today's Task"), findsOneWidget);
    expect(find.text('Task Ready'), findsOneWidget);
    expect(find.text('Start Task'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.textContaining('Daily limit'), findsOneWidget);
  });
}
