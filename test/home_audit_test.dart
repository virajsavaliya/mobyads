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
  testWidgets('Home header audit: 48px targets + semantics', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(_OfflineApiClient()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Screen-reader label on avatar action (widget-level: Semantics node)
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == 'Open profile' &&
            w.properties.button == true,
      ),
      findsOneWidget,
    );

    // Notification bell hit area meets 48px minimum (outer SizedBox).
    // Note: IconButton's inner visual is smaller; the 48px SizedBox +
    // circular container is the tappable region.
    final bell = find.widgetWithIcon(
      IconButton,
      Icons.notifications_none_rounded,
    );
    expect(bell, findsOneWidget);
    Size? hitSize;
    bell.evaluate().single.visitAncestorElements((a) {
      if (a.widget is SizedBox && a.size != null) {
        final s = a.size!;
        if (hitSize == null ||
            s.width * s.height > hitSize!.width * hitSize!.height) {
          hitSize = s;
        }
      }
      return true;
    });
    expect(hitSize, isNotNull);
    expect(hitSize!.width, greaterThanOrEqualTo(48));
    expect(hitSize!.height, greaterThanOrEqualTo(48));
  });
}
