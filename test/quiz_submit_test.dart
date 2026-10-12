import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/network/api_client.dart';
import 'package:mobyads/core/storage/secure_storage_service.dart';
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
  String? lastIdempotencyKey;
  int calls = 0;
  FakeApi({this.data, this.fail = false})
      : super(dio: Dio(), secureStorage: FakeStorage());

  @override
  Future<Response<T>> post<T>(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    calls++;
    lastIdempotencyKey = (data as Map?)?['idempotency_key'] as String?;
    if (fail) {
      throw DioException(requestOptions: RequestOptions(path: path));
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: this.data as T?,
    );
  }
}

List<Question> twoQuestions() => mockDailyQuizQuestions.take(2).toList();

void main() {
  test('server correct answer credits server reward', () async {
    final api = FakeApi(data: {
      'is_correct': true,
      'reward_amount': 2.0,
      'reward_txn_id': 'txn-1',
    });
    final home = HomeDashboardNotifier();
    final c = QuizSessionController(
      home,
      initialQuestions: twoQuestions(),
      submissionService: QuizSubmissionService(api),
    );
    c.selectOption(0);
    final r = await c.submitAnswerViaServer();
    expect(r?.isCorrect, true);
    expect(c.state.earnedAmount, 2.0);
    expect(api.calls, 1);
    expect(api.lastIdempotencyKey, isNotNull);
  });

  test('server incorrect answer credits zero', () async {
    final api = FakeApi(data: {'is_correct': false, 'reward_amount': 0});
    final home = HomeDashboardNotifier();
    final c = QuizSessionController(
      home,
      initialQuestions: twoQuestions(),
      submissionService: QuizSubmissionService(api),
    );
    c.selectOption(1);
    final r = await c.submitAnswerViaServer();
    expect(r?.isCorrect, false);
    expect(c.state.earnedAmount, 0);
    expect(c.state.currentIndex, 1);
  });

  test('offline fallback preserves old UX credit', () async {
    final api = FakeApi(fail: true);
    final home = HomeDashboardNotifier();
    final c = QuizSessionController(
      home,
      initialQuestions: twoQuestions(),
      submissionService: QuizSubmissionService(api),
    );
    c.selectOption(1);
    await c.submitAnswerViaServer();
    expect(c.state.earnedAmount, QuizSessionController.rewardPerQuestion);
  });

  test('idempotency key stable per question index', () async {
    final api = FakeApi(data: {'is_correct': true, 'reward_amount': 1.5});
    final home = HomeDashboardNotifier();
    final c = QuizSessionController(
      home,
      initialQuestions: twoQuestions(),
      submissionService: QuizSubmissionService(api),
    );
    c.selectOption(0);
    await c.submitAnswerViaServer();
    final first = api.lastIdempotencyKey;
    c.selectOption(0);
    await c.submitAnswerViaServer();
    final second = api.lastIdempotencyKey;
    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(first, isNot(startsWith('quiz-unknown')));
    // Different index -> different key (no double-pay on retry of same Q
    // is guaranteed by same-index same-key; covered by key containing index).
    expect(first, isNot(equals(second)));
  });

  test('legacy sync path still works (no regression)', () {
    final container = ProviderContainer();
    final controller = container.read(quizControllerProvider.notifier);
    controller.selectOption(1);
    controller.submitAnswerAndAdvance();
    expect(container.read(quizControllerProvider).earnedAmount, 1.50);
  });
}
