import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../models/server_contract.dart';

// Server-validated quiz submission (PDF §7).
// Client reports answer; server decides correctness + reward.
class QuizSubmitResult {
  final bool isCorrect;
  final String? rewardTxnId;
  final double rewardAmount;

  const QuizSubmitResult({
    required this.isCorrect,
    this.rewardTxnId,
    this.rewardAmount = 0,
  });
}

class QuizSubmissionService {
  final ApiClient _api;
  QuizSubmissionService(this._api);

  Future<QuizSubmitResult> submit({
    required String questionId,
    required int selectedIndex,
    required String idempotencyKey,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.submitQuiz,
      data: quizSubmitBody(
        questionId: questionId,
        selectedIndex: selectedIndex,
        idempotencyKey: idempotencyKey,
      ),
    );
    final data = res.data ?? const <String, dynamic>{};
    return QuizSubmitResult(
      isCorrect: data['is_correct'] as bool? ?? data['isCorrect'] as bool? ?? false,
      rewardTxnId: data['reward_txn_id'] as String? ?? data['rewardTxnId'] as String?,
      rewardAmount: (data['reward_amount'] as num?)?.toDouble() ??
          (data['rewardAmount'] as num?)?.toDouble() ??
          0,
    );
  }
}
