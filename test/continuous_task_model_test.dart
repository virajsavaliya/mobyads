import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/core/config/server_config_provider.dart';
import 'package:mobyads/core/network/api_client.dart';
import 'package:mobyads/core/storage/secure_storage_service.dart';
import 'package:mobyads/features/home/models/home_dashboard_state.dart';
import 'package:mobyads/features/home/providers/home_dashboard_provider.dart';
import 'package:mobyads/features/home/screens/home_screen.dart';
import 'package:mobyads/features/mcq/controllers/quiz_controller.dart';
import 'package:mobyads/features/mcq/models/question_model.dart';
import 'package:mobyads/features/mcq/models/quiz_state.dart';
import 'package:mobyads/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

List<Override> _offlineOverrides([
  List<Override> extra = const [],
]) => [
  apiClientProvider.overrideWithValue(_OfflineApiClient()),
  ...extra,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Continuous 24/7 Rolling Task Model Unit & Logic Tests', () {
    test('A brand new user very first task is AVAILABLE immediately with no wait', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = HomeDashboardNotifier();
      // Allow async _initFromStorage to execute
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.currentTask.status, TaskStatus.available);
      expect(notifier.state.currentTask.unlockAt, isNull);
      expect(notifier.state.remainingCooldown, Duration.zero);
      expect(notifier.state.isTaskAvailable, isTrue);
      notifier.dispose();
    });

    test('Starting a quiz transitions task status to IN_PROGRESS', () async {
      final notifier = HomeDashboardNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.currentTask.status, TaskStatus.available);
      notifier.startTask();
      expect(notifier.state.currentTask.status, TaskStatus.inProgress);
      expect(notifier.state.isTaskInProgress, isTrue);
      notifier.dispose();
    });

    test('Completing a task marks next task LOCKED with live 1-hour cooldown', () async {
      final notifier = HomeDashboardNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final completionTime = DateTime(2026, 9, 1, 14, 0, 0);
      notifier.recordQuizCompleted(
        rewardAmount: 15.00,
        completionTime: completionTime,
      );

      final state = notifier.state;
      expect(state.currentTask.status, TaskStatus.locked);
      expect(state.isTaskLocked, isTrue);
      expect(state.currentTask.completedAt, completionTime);
      expect(
        state.currentTask.unlockAt,
        completionTime.add(const Duration(hours: 1)),
      );
      expect(state.tasksCompletedToday, 1);
      expect(state.remainingCooldown.inMinutes, 60);
      expect(state.formattedRemainingTime, '01:00:00');
      notifier.dispose();
    });

    test('Automatic Flip to AVAILABLE when countdown reaches zero', () async {
      final notifier = HomeDashboardNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final completionTime = DateTime(2026, 9, 1, 14, 0, 0);
      notifier.recordQuizCompleted(
        rewardAmount: 15.00,
        completionTime: completionTime,
      );

      expect(notifier.state.currentTask.status, TaskStatus.locked);

      // Simulate clock reaching 30 minutes in
      notifier.applyCooldownTick(
        simulatedNow: completionTime.add(const Duration(minutes: 30)),
      );
      expect(notifier.state.currentTask.status, TaskStatus.locked);
      expect(notifier.state.formattedRemainingTime, '30:00');

      // Simulate clock reaching 59 minutes and 50 seconds
      notifier.applyCooldownTick(
        simulatedNow: completionTime.add(const Duration(minutes: 59, seconds: 50)),
      );
      expect(notifier.state.formattedRemainingTime, '00:10');

      // Simulate clock reaching 1 hour (cooldown elapsed)
      notifier.applyCooldownTick(
        simulatedNow: completionTime.add(const Duration(hours: 1)),
      );
      expect(notifier.state.currentTask.status, TaskStatus.available);
      expect(notifier.state.currentTask.unlockAt, isNull);
      expect(notifier.state.remainingCooldown, Duration.zero);
      expect(notifier.state.isTaskAvailable, isTrue);
      notifier.dispose();
    });

    test('Mock completing at 11:58 PM -> Unlocks at 12:58 AM uninterrupted across midnight', () async {
      final notifier = HomeDashboardNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // 11:58 PM on Sept 1, 2026
      final lateNightTime = DateTime(2026, 9, 1, 23, 58, 0);
      notifier.recordQuizCompleted(
        rewardAmount: 15.00,
        completionTime: lateNightTime,
      );

      // Next unlock is 12:58 AM on Sept 2, 2026
      final expectedUnlock = DateTime(2026, 9, 2, 0, 58, 0);
      expect(notifier.state.currentTask.unlockAt, expectedUnlock);
      expect(notifier.state.currentTask.status, TaskStatus.locked);
      expect(notifier.state.tasksCompletedToday, 1);

      // Simulate crossing midnight: 12:15 AM on Sept 2
      final pastMidnight = DateTime(2026, 9, 2, 0, 15, 0);
      notifier.applyCooldownTick(simulatedNow: pastMidnight);

      // Tasks Today display resets for the new calendar day, but cooldown keeps ticking!
      expect(notifier.state.tasksCompletedToday, 0);
      expect(notifier.state.currentTask.status, TaskStatus.locked);
      expect(notifier.state.formattedRemainingTime, '43:00');

      // Simulate reaching 12:58 AM on Sept 2
      notifier.applyCooldownTick(simulatedNow: expectedUnlock);
      expect(notifier.state.currentTask.status, TaskStatus.available);
      expect(notifier.state.currentTask.unlockAt, isNull);
      notifier.dispose();
    });

    test('Force-close and reopen app mid-countdown resumes from stored unlockAt timestamp', () async {
      // Simulate stored state in SharedPreferences: unlockAt is 35 minutes from now
      final now = DateTime.now();
      final unlockTime = now.add(const Duration(minutes: 35));

      SharedPreferences.setMockInitialValues({
        'mobyad_task_unlock_at': unlockTime.toIso8601String(),
        'mobyad_task_status': 'locked',
        'mobyad_task_completed_at': now.subtract(const Duration(minutes: 25)).toIso8601String(),
        'mobyad_tasks_completed_today': 2,
        'mobyad_last_completed_date': now.toIso8601String(),
      });

      // App re-launches with new notifier instance
      final reloadedNotifier = HomeDashboardNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = reloadedNotifier.state;
      expect(state.currentTask.status, TaskStatus.locked);
      expect(state.currentTask.unlockAt, isNotNull);
      expect(state.remainingCooldown.inMinutes, closeTo(35, 1));
      expect(state.tasksCompletedToday, 2);
      reloadedNotifier.dispose();
    });

    test('10-MCQ quiz completion via QuizSessionController triggers continuous task locked cooldown', () async {
      final homeNotifier = HomeDashboardNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final quizController = QuizSessionController(
        homeNotifier,
        initialQuestions: mockDailyQuizQuestions.take(10).toList(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Starts in progress
      expect(homeNotifier.state.currentTask.status, TaskStatus.inProgress);

      // Answer all 10 questions
      for (int i = 0; i < 10; i++) {
        quizController.selectOption(0);
        quizController.submitCurrentAnswer();
        quizController.onAdFinished();
      }

      expect(quizController.state.step, QuizStep.completed);
      // Home task state transitioned to LOCKED with 1-hour cooldown
      expect(homeNotifier.state.currentTask.status, TaskStatus.locked);
      expect(homeNotifier.state.isTaskLocked, isTrue);
      expect(homeNotifier.state.tasksCompletedToday, 1);
      expect(homeNotifier.state.availableBalance, 15.00);

      homeNotifier.dispose();
    });
  });

  group('HomeScreen Dynamic Task Card Widget Tests', () {
    testWidgets('Displays AVAILABLE state with "Task Ready" and "Start Task" button', (tester) async {
      final homeState = const HomeDashboardState(
        currentTask: TaskModel(
          id: 'task_1',
          status: TaskStatus.available,
          rewardAmount: 15.00,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _offlineOverrides([
            homeDashboardProvider.overrideWith(
              (ref) => HomeDashboardNotifier(initialState: homeState),
            ),
          ]),
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Task Ready'), findsOneWidget);
      expect(find.text('Earn up to ₹15.00'), findsOneWidget);
      expect(find.text('Start Task'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Tasks Today'), findsOneWidget);
    });

    testWidgets('Displays LOCKED state with live countdown timer and Cooldown badge', (tester) async {
      final homeState = HomeDashboardState(
        currentTask: TaskModel(
          id: 'task_1',
          status: TaskStatus.locked,
          rewardAmount: 15.00,
          unlockAt: DateTime.now().add(const Duration(minutes: 48, seconds: 20)),
        ),
        remainingCooldown: const Duration(minutes: 48, seconds: 20),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _offlineOverrides([
            homeDashboardProvider.overrideWith(
              (ref) => HomeDashboardNotifier(initialState: homeState),
            ),
          ]),
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Next Task Locked'), findsOneWidget);
      expect(find.text('Next task unlocks in'), findsOneWidget);
      expect(find.text('48:20'), findsOneWidget);
      expect(find.text('Cooldown'), findsOneWidget);
      expect(find.text('Unlocks automatically when countdown reaches zero'), findsOneWidget);
    });

    testWidgets('Displays IN_PROGRESS state with "Continue Task" button', (tester) async {
      final homeState = const HomeDashboardState(
        currentTask: TaskModel(
          id: 'task_1',
          status: TaskStatus.inProgress,
          rewardAmount: 15.00,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _offlineOverrides([
            homeDashboardProvider.overrideWith(
              (ref) => HomeDashboardNotifier(initialState: homeState),
            ),
          ]),
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Task In Progress'), findsOneWidget);
      expect(find.text('Continue Task'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
    });
  });
}
