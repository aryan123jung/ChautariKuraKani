import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/call/data/datasources/call_datasource.dart';
import 'package:chautari_kurakani/features/call/data/models/call_api_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final callRemoteDatasourceProvider = Provider<ICallRemoteDatasource>((ref) {
  return CallRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class CallRemoteDatasource implements ICallRemoteDatasource {
  final ApiClient _apiClient;

  CallRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<CallLogApiModel>> listMyCalls({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.calls,
      queryParameters: {'page': page, 'size': size},
    );

    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map((item) => CallLogApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
