/// Status of a continuous rolling task
enum TaskStatus {
  locked,
  available,
  inProgress;

  static TaskStatus fromString(String? value) {
    switch (value) {
      case 'locked':
        return TaskStatus.locked;
      case 'inProgress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'available':
      default:
        return TaskStatus.available;
    }
  }

  String get nameString {
    switch (this) {
      case TaskStatus.locked:
        return 'locked';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.available:
        return 'available';
    }
  }
}

/// Continuous rolling task model (Runs 24/7 with 1-hour cooldown upon completion)
class TaskModel {
  final String id;
  final String title;
  final String description;
  final double rewardAmount;
  final int rewardCoins;
  final String taskType; // 'quiz', 'ad', 'survey'
  final TaskStatus status;
  final DateTime? unlockAt;
  final DateTime? completedAt;

  const TaskModel({
    required this.id,
    this.title = 'Daily News Quiz — 10 Questions',
    this.description = 'Answer 10 current affairs MCQs to earn guaranteed rewards.',
    this.rewardAmount = 15.00,
    this.rewardCoins = 1500,
    this.taskType = 'quiz',
    this.status = TaskStatus.available,
    this.unlockAt,
    this.completedAt,
  });

  bool get isAvailable => status == TaskStatus.available;
  bool get isLocked => status == TaskStatus.locked;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isCompleted => completedAt != null;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    double? rewardAmount,
    int? rewardCoins,
    String? taskType,
    TaskStatus? status,
    DateTime? unlockAt,
    DateTime? completedAt,
    bool clearUnlockAt = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      unlockAt: clearUnlockAt ? null : (unlockAt ?? this.unlockAt),
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? 'task_initial',
      title: json['title'] as String? ?? 'Daily News Quiz — 10 Questions',
      description: json['description'] as String? ??
          'Answer 10 current affairs MCQs to earn guaranteed rewards.',
      rewardAmount: (json['reward_amount'] as num?)?.toDouble() ?? 15.00,
      rewardCoins: json['reward_coins'] as int? ?? 1500,
      taskType: json['task_type'] as String? ?? 'quiz',
      status: TaskStatus.fromString(json['status'] as String?),
      unlockAt: json['unlock_at'] != null
          ? DateTime.tryParse(json['unlock_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'reward_amount': rewardAmount,
        'reward_coins': rewardCoins,
        'task_type': taskType,
        'status': status.nameString,
        'unlock_at': unlockAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };
}
