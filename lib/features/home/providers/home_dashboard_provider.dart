import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/app_logger.dart';
import '../../../models/task_model.dart';
import '../models/home_dashboard_state.dart';

final homeDashboardProvider =
    StateNotifierProvider<HomeDashboardNotifier, HomeDashboardState>((ref) {
  return HomeDashboardNotifier();
});

class HomeDashboardNotifier extends StateNotifier<HomeDashboardState> {
  Timer? _cooldownTimer;

  static const String _keyUnlockAt = 'mobyad_task_unlock_at';
  static const String _keyStatus = 'mobyad_task_status';
  static const String _keyCompletedAt = 'mobyad_task_completed_at';
  static const String _keyTasksToday = 'mobyad_tasks_completed_today';
  static const String _keyLastCompletedDate = 'mobyad_last_completed_date';
  static const String _keyAvailableBalance = 'mobyad_available_balance';
  static const String _keyTotalEarned = 'mobyad_total_earned';

  HomeDashboardNotifier({HomeDashboardState? initialState})
      : super(initialState ?? const HomeDashboardState()) {
    _initFromStorage();
  }

  /// Initializes state from local storage or sets brand new user defaults
  Future<void> _initFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final unlockAtStr = prefs.getString(_keyUnlockAt);
      final statusStr = prefs.getString(_keyStatus);
      final completedAtStr = prefs.getString(_keyCompletedAt);
      final tasksToday = prefs.getInt(_keyTasksToday) ?? state.tasksCompletedToday;
      final lastDateStr = prefs.getString(_keyLastCompletedDate);
      final savedBalance = prefs.getDouble(_keyAvailableBalance);
      final savedTotal = prefs.getDouble(_keyTotalEarned);

      DateTime? unlockAt =
          unlockAtStr != null ? DateTime.tryParse(unlockAtStr) : null;
      DateTime? completedAt =
          completedAtStr != null ? DateTime.tryParse(completedAtStr) : null;
      DateTime? lastDate =
          lastDateStr != null ? DateTime.tryParse(lastDateStr) : null;

      final now = DateTime.now();

      // Check if calendar date rolled over at midnight (for display chip ONLY)
      int evaluatedTasksToday = tasksToday;
      if (lastDate != null) {
        final isSameCalendarDay = lastDate.year == now.year &&
            lastDate.month == now.month &&
            lastDate.day == now.day;
        if (!isSameCalendarDay) {
          evaluatedTasksToday = 0;
        }
      }

      TaskStatus taskStatus;
      Duration remaining = Duration.zero;

      if (unlockAt != null && unlockAt.isAfter(now)) {
        // Active cooldown running across sessions
        taskStatus = TaskStatus.locked;
        remaining = unlockAt.difference(now);
      } else if (statusStr == 'in_progress' || statusStr == 'inProgress') {
        taskStatus = TaskStatus.inProgress;
      } else {
        // Brand new user or cooldown elapsed
        taskStatus = TaskStatus.available;
        unlockAt = null;
      }

      state = state.copyWith(
        availableBalance: savedBalance ?? state.availableBalance,
        totalEarned: savedTotal ?? state.totalEarned,
        tasksCompletedToday: evaluatedTasksToday,
        lastCompletedDate: lastDate,
        remainingCooldown: remaining,
        currentTask: state.currentTask.copyWith(
          status: taskStatus,
          unlockAt: unlockAt,
          completedAt: completedAt,
          clearUnlockAt: taskStatus == TaskStatus.available,
        ),
      );

      if (taskStatus == TaskStatus.locked && unlockAt != null) {
        _startTicker(unlockAt);
      }
    } catch (e) {
      AppLogger.e('Error loading task state from storage: $e');
    }
  }

  /// Sets task to in-progress when quiz session starts
  void startTask() {
    if (state.currentTask.status == TaskStatus.locked) return;

    state = state.copyWith(
      currentTask: state.currentTask.copyWith(
        status: TaskStatus.inProgress,
      ),
    );
    _saveToStorage();
  }

  /// Called the moment a 10-MCQ task is completed.
  /// Next task enters LOCKED status with unlockAt = now + 1 hour.
  void recordQuizCompleted({
    double rewardAmount = 15.00,
    DateTime? completionTime,
  }) {
    _cooldownTimer?.cancel();

    final now = completionTime ?? DateTime.now();
    final nextUnlockAt = now.add(const Duration(hours: 1));

    // Calendar day display counter update (resets at midnight local time)
    int updatedTasksToday = 1;
    if (state.lastCompletedDate != null) {
      final isSameCalendarDay = state.lastCompletedDate!.year == now.year &&
          state.lastCompletedDate!.month == now.month &&
          state.lastCompletedDate!.day == now.day;
      if (isSameCalendarDay) {
        updatedTasksToday = state.tasksCompletedToday + 1;
      }
    }

    final newBalance = state.availableBalance + rewardAmount;
    final newTotalEarned = state.totalEarned + rewardAmount;

    final updatedTask = state.currentTask.copyWith(
      id: 'task_${now.millisecondsSinceEpoch}',
      status: TaskStatus.locked,
      unlockAt: nextUnlockAt,
      completedAt: now,
    );

    final remaining = nextUnlockAt.difference(now);

    state = state.copyWith(
      availableBalance: newBalance,
      totalEarned: newTotalEarned,
      tasksCompletedToday: updatedTasksToday,
      lastCompletedDate: now,
      currentTask: updatedTask,
      remainingCooldown: remaining,
    );

    _saveToStorage();
    _startTicker(nextUnlockAt);
  }

  /// Ticks every second and automatically unlocks when countdown hits zero
  void _startTicker(DateTime unlockAt) {
    _cooldownTimer?.cancel();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      // Check calendar date display roll (does NOT interrupt cooldown timer)
      _checkCalendarMidnight(now);

      final diff = unlockAt.difference(now);

      if (diff <= Duration.zero) {
        timer.cancel();
        _cooldownTimer = null;

        state = state.copyWith(
          remainingCooldown: Duration.zero,
          currentTask: state.currentTask.copyWith(
            status: TaskStatus.available,
            clearUnlockAt: true,
          ),
        );
        _saveToStorage();
        AppLogger.i('Task cooldown reached 0. Task flipped to AVAILABLE automatically.');
      } else {
        state = state.copyWith(remainingCooldown: diff);
      }
    });
  }

  /// Checks if calendar day changed since last check and updates "Tasks Today"
  void _checkCalendarMidnight(DateTime now) {
    if (state.lastCompletedDate != null) {
      final isSameCalendarDay = state.lastCompletedDate!.year == now.year &&
          state.lastCompletedDate!.month == now.month &&
          state.lastCompletedDate!.day == now.day;
      if (!isSameCalendarDay && state.tasksCompletedToday > 0) {
        state = state.copyWith(tasksCompletedToday: 0);
      }
    }
  }

  /// Simulates refreshing dashboard data
  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    _checkCalendarMidnight(now);

    final unlockAt = state.currentTask.unlockAt;
    if (state.currentTask.status == TaskStatus.locked && unlockAt != null) {
      final diff = unlockAt.difference(now);
      if (diff <= Duration.zero) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
        state = state.copyWith(
          remainingCooldown: Duration.zero,
          currentTask: state.currentTask.copyWith(
            status: TaskStatus.available,
            clearUnlockAt: true,
          ),
        );
        _saveToStorage();
      } else {
        state = state.copyWith(remainingCooldown: diff);
      }
    }
  }

  /// Explicit testing / debug method: immediately unlock task
  void forceUnlockTask() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    state = state.copyWith(
      remainingCooldown: Duration.zero,
      currentTask: state.currentTask.copyWith(
        status: TaskStatus.available,
        clearUnlockAt: true,
      ),
    );
    _saveToStorage();
  }

  /// Fast-forwards or updates the remaining cooldown for testing
  void applyCooldownTick({required DateTime simulatedNow}) {
    _checkCalendarMidnight(simulatedNow);
    final unlockAt = state.currentTask.unlockAt;
    if (unlockAt != null) {
      final diff = unlockAt.difference(simulatedNow);
      if (diff <= Duration.zero) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
        state = state.copyWith(
          remainingCooldown: Duration.zero,
          currentTask: state.currentTask.copyWith(
            status: TaskStatus.available,
            clearUnlockAt: true,
          ),
        );
      } else {
        state = state.copyWith(remainingCooldown: diff);
      }
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final task = state.currentTask;

      if (task.unlockAt != null) {
        await prefs.setString(_keyUnlockAt, task.unlockAt!.toIso8601String());
      } else {
        await prefs.remove(_keyUnlockAt);
      }

      await prefs.setString(_keyStatus, task.status.nameString);

      if (task.completedAt != null) {
        await prefs.setString(_keyCompletedAt, task.completedAt!.toIso8601String());
      }

      await prefs.setInt(_keyTasksToday, state.tasksCompletedToday);

      if (state.lastCompletedDate != null) {
        await prefs.setString(
          _keyLastCompletedDate,
          state.lastCompletedDate!.toIso8601String(),
        );
      }

      await prefs.setDouble(_keyAvailableBalance, state.availableBalance);
      await prefs.setDouble(_keyTotalEarned, state.totalEarned);
    } catch (e) {
      AppLogger.e('Error saving task state to storage: $e');
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
