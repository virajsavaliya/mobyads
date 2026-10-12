import '../../../models/task_model.dart';

/// State model for Home Dashboard & 24/7 Rolling Tasks
class HomeDashboardState {
  final double availableBalance;
  final double pendingBalance;
  final double totalEarned;
  final int tasksCompletedToday;
  final int adsWatchedToday;
  final TaskModel currentTask;
  final Duration remainingCooldown;
  final DateTime? lastCompletedDate;

  const HomeDashboardState({
    this.availableBalance = 0,
    this.pendingBalance = 0,
    this.totalEarned = 0,
    this.tasksCompletedToday = 0,
    this.adsWatchedToday = 0,
    this.currentTask = const TaskModel(
      id: 'task_current',
      status: TaskStatus.available,
    ),
    this.remainingCooldown = Duration.zero,
    this.lastCompletedDate,
  });

  bool get isTaskAvailable => currentTask.status == TaskStatus.available;
  bool get isTaskLocked => currentTask.status == TaskStatus.locked;
  bool get isTaskInProgress => currentTask.status == TaskStatus.inProgress;

  /// Formatted countdown string (HH:MM:SS if >= 1hr, or MM:SS if < 1hr)
  String get formattedRemainingTime {
    if (remainingCooldown <= Duration.zero) {
      return '00:00';
    }
    final hours = remainingCooldown.inHours;
    final minutes = remainingCooldown.inMinutes.remainder(60);
    final seconds = remainingCooldown.inSeconds.remainder(60);

    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final hStr = hours.toString().padLeft(2, '0');
      return '$hStr:$mStr:$sStr';
    }
    return '$mStr:$sStr';
  }

  HomeDashboardState copyWith({
    double? availableBalance,
    double? pendingBalance,
    double? totalEarned,
    int? tasksCompletedToday,
    int? adsWatchedToday,
    TaskModel? currentTask,
    Duration? remainingCooldown,
    DateTime? lastCompletedDate,
  }) {
    return HomeDashboardState(
      availableBalance: availableBalance ?? this.availableBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      tasksCompletedToday: tasksCompletedToday ?? this.tasksCompletedToday,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
      currentTask: currentTask ?? this.currentTask,
      remainingCooldown: remainingCooldown ?? this.remainingCooldown,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }
}
