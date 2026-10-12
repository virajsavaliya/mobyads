// Server-driven public config (PDF §18). Backend is authority, app falls back
// to these defaults when offline so existing behavior is preserved.
class ServerConfig {
  final double minWithdrawal;
  final double dailyLimit;
  final int taskCooldownMinutes;
  final int mcqCount;
  final double rewardMcq;
  final double rewardAd;
  final String currency;

  const ServerConfig({
    this.minWithdrawal = 50.0,
    this.dailyLimit = 1000.0,
    this.taskCooldownMinutes = 60,
    this.mcqCount = 10,
    this.rewardMcq = 1.50,
    this.rewardAd = 2.00,
    this.currency = 'INR',
  });

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    double d(Object? v, double fb) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? fb;
    int i(Object? v, int fb) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? fb;
    return ServerConfig(
      minWithdrawal: d(json['min_withdrawal'] ?? json['minWithdrawal'], 50.0),
      dailyLimit: d(json['daily_limit'] ?? json['dailyLimit'], 1000.0),
      taskCooldownMinutes:
          i(json['task_cooldown_minutes'] ?? json['taskCooldownMinutes'], 60),
      mcqCount: i(json['mcq_count'] ?? json['mcqCount'], 10),
      rewardMcq: d(json['reward_mcq'] ?? json['rewardMcq'], 1.50),
      rewardAd: d(json['reward_ad'] ?? json['rewardAd'], 2.00),
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}
