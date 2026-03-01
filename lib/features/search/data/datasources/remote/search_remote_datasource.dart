import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/search/data/datasources/search_datasource.dart';
import 'package:chautari_kurakani/features/search/data/models/search_user_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRemoteDatasourceProvider = Provider<ISearchRemoteDatasource>((ref) {
  return SearchRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class SearchRemoteDatasource implements ISearchRemoteDatasource {
  final ApiClient _apiClient;

  SearchRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<SearchUserApiModel>> searchUsers({
    required String query,
    int page = 1,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.authUsers,
      queryParameters: {
        'page': page,
        'size': size,
        if (query.trim().isNotEmpty) 'search': query.trim(),
      },
    );

    final rawUsers = response.data['data'] as List<dynamic>? ?? [];
    return rawUsers
        .map(
          (item) => SearchUserApiModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
