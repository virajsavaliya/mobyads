import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import 'server_config.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final serverConfigProvider =
    StateNotifierProvider<ServerConfigController, ServerConfig>(
        (ref) => ServerConfigController(ref.watch(apiClientProvider)));

class ServerConfigController extends StateNotifier<ServerConfig> {
  final ApiClient _api;
  bool loadedFromServer = false;

  ServerConfigController(this._api) : super(const ServerConfig());

  Future<void> load() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiEndpoints.publicConfig);
      final data = res.data;
      if (data != null) {
        state = ServerConfig.fromJson(data);
        loadedFromServer = true;
      }
    } on DioException {
      // Offline / no backend yet (M2-M3 contract only): keep defaults.
      loadedFromServer = false;
    }
  }
}
