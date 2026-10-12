/// API Endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/me';

  // Tasks & MCQ (M2-M3 contract: server validates, client never sees answer)
  static const String tasks = '/tasks/today';
  static const String taskDetails = '/tasks/';
  static const String completeTask = '/tasks/complete';
  static const String quizzes = '/quizzes/today';
  static const String submitQuiz = '/quizzes/submit';

  // Ads & Earnings (M4 ready: reward-session + SSV, no client-side credit)
  static const String rewardSession = '/reward-sessions';
  static const String adRewardVerify = '/ads/ssv-callback';
  static const String dailyReward = '/rewards/daily';

  // Wallet & Withdrawals (ledger-derived, idempotencyKey required on POST)
  static const String wallet = '/wallet';
  static const String transactions = '/wallet/transactions';
  static const String withdraw = '/withdrawals';
  static const String withdrawalHistory = '/withdrawals';

  // Server-driven config (PDF §18) + coupons (M5 ready)
  static const String publicConfig = '/config/public';
  static const String myCoupons = '/coupons/me';
  static const String payoutMethods = '/payout-methods';
}
