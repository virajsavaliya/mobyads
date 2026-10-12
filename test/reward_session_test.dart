import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/network/api_client.dart';
import 'package:mobyads/core/storage/secure_storage_service.dart';
import 'package:mobyads/features/ads/services/reward_session_service.dart';
import 'package:mobyads/features/home/providers/home_dashboard_provider.dart';
import 'package:mobyads/features/mcq/controllers/quiz_controller.dart';
import 'package:mobyads/features/mcq/models/question_model.dart';
import 'package:mobyads/features/mcq/services/quiz_submission_service.dart';

class FakeStorage extends SecureStorageService {
  @override
  Future<String?> getToken() async => null;
}

class FakeApi extends ApiClient {
  final Map<String, dynamic>? data;
  final bool fail;
  Map<String, dynamic>? lastBody;
  FakeApi({this.data, this.fail = false})
      : super(dio: Dio(), secureStorage: FakeStorage());

  @override
  Future<Response<T>> post<T>(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    lastBody = data as Map<String, dynamic>?;
    if (fail) throw DioException(requestOptions: RequestOptions(path: path));
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: this.data as T?,
    );
  }
}

void main() {
  test('creates server session id', () async {
    final api = FakeApi(data: {'session_id': 'sess-abc-123'});
    final svc = RewardSessionService(api);
    final r = await svc.create();
    expect(r.sessionId, 'sess-abc-123');
    expect(r.isFallback, false);
    expect(api.lastBody?['task_type'], 'REWARDED_AD');
  });

  test('offline generates opaque local fallback', () async {
    final svc = RewardSessionService(FakeApi(fail: true));
    final r = await svc.create();
    expect(r.sessionId, startsWith('local-'));
    expect(r.isFallback, true);
  });

  test('controller stores active session before ad show', () async {
    final sessionApi = FakeApi(data: {'session_id': 'sess-q5'});
    final home = HomeDashboardNotifier();
    final c = QuizSessionController(
      home,
      initialQuestions: mockDailyQuizQuestions.take(10).toList(),
      submissionService: QuizSubmissionService(FakeApi(
        data: {'is_correct': true, 'reward_amount': 1.5},
      )),
      rewardSessionService: RewardSessionService(sessionApi),
    );
    final id = await c.beginRewardSession();
    expect(id, 'sess-q5');
    expect(c.state.activeRewardSessionId, 'sess-q5');
  });
}
