import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationPreferencesState {
  final bool taskReminders;
  final bool rewardCredited;
  final bool withdrawalUpdates;
  final bool couponsAndOffers;

  const NotificationPreferencesState({
    this.taskReminders = true,
    this.rewardCredited = true,
    this.withdrawalUpdates = true,
    this.couponsAndOffers = false,
  });

  NotificationPreferencesState copyWith({
    bool? taskReminders,
    bool? rewardCredited,
    bool? withdrawalUpdates,
    bool? couponsAndOffers,
  }) {
    return NotificationPreferencesState(
      taskReminders: taskReminders ?? this.taskReminders,
      rewardCredited: rewardCredited ?? this.rewardCredited,
      withdrawalUpdates: withdrawalUpdates ?? this.withdrawalUpdates,
      couponsAndOffers: couponsAndOffers ?? this.couponsAndOffers,
    );
  }
}

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesController, NotificationPreferencesState>((ref) {
  return NotificationPreferencesController();
});

class NotificationPreferencesController
    extends StateNotifier<NotificationPreferencesState> {
  NotificationPreferencesController()
      : super(const NotificationPreferencesState());

  void toggleTaskReminders(bool value) {
    state = state.copyWith(taskReminders: value);
  }

  void toggleRewardCredited(bool value) {
    state = state.copyWith(rewardCredited: value);
  }

  void toggleWithdrawalUpdates(bool value) {
    state = state.copyWith(withdrawalUpdates: value);
  }

  void toggleCouponsAndOffers(bool value) {
    state = state.copyWith(couponsAndOffers: value);
  }
}
