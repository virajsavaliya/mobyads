import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

// Opaque reward session for AdMob SSV custom-data (PDF §11-12).
// Backend is authority; client only attaches the id, never credits from it.
class RewardSessionResult {
  final String sessionId;
  final bool isFallback;
  const RewardSessionResult(this.sessionId, {this.isFallback = false});
}

class RewardSessionService {
  final ApiClient _api;
  RewardSessionService(this._api);

  Future<RewardSessionResult> create({String taskType = 'REWARDED_AD'}) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.rewardSession,
        data: {'task_type': taskType},
      );
      final data = res.data ?? const {};
      final id = (data['session_id'] ?? data['sessionId'] ?? '') as String;
      if (id.isEmpty) throw Exception('empty session');
      return RewardSessionResult(id);
    } catch (_) {
      // Offline transition: opaque local id, backend will reconcile later.
      final fallback =
          'local-${DateTime.now().millisecondsSinceEpoch}';
      return RewardSessionResult(fallback, isFallback: true);
    }
  }
}
