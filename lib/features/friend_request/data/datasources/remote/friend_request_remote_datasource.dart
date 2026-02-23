import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/friend_request/data/datasources/friend_request_datasource.dart';
import 'package:chautari_kurakani/features/friend_request/data/models/friend_request_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendRequestRemoteDatasourceProvider =
    Provider<IFriendRequestRemoteDatasource>((ref) {
      return FriendRequestRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class FriendRequestRemoteDatasource implements IFriendRequestRemoteDatasource {
  final ApiClient _apiClient;

  FriendRequestRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<FriendRequestApiModel> sendRequest(String toUserId) async {
    final response = await _apiClient.post(
      ApiEndpoints.sendFriendRequest(toUserId),
    );
    return FriendRequestApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cancelRequest(String toUserId) async {
    await _apiClient.delete(ApiEndpoints.cancelFriendRequest(toUserId));
  }

  @override
  Future<FriendRequestApiModel> acceptRequest(String requestId) async {
    final response = await _apiClient.post(
      ApiEndpoints.acceptFriendRequest(requestId),
    );
    return FriendRequestApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<FriendRequestApiModel> rejectRequest(String requestId) async {
    final response = await _apiClient.post(
      ApiEndpoints.rejectFriendRequest(requestId),
    );
    return FriendRequestApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> unfriend(String friendUserId) async {
    await _apiClient.delete(ApiEndpoints.unfriend(friendUserId));
  }

  @override
  Future<FriendStatusApiModel> getStatus(String userId) async {
    final response = await _apiClient.get(ApiEndpoints.friendStatus(userId));
    return FriendStatusApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<int> getFriendCount(String userId) async {
    final response = await _apiClient.get(ApiEndpoints.friendCount(userId));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final countRaw = data['count'];
    if (countRaw is int) return countRaw;
    return int.tryParse(countRaw?.toString() ?? '0') ?? 0;
  }

  @override
  Future<List<FriendRequestApiModel>> getIncoming({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.incomingFriendRequests,
      queryParameters: {'page': page, 'size': size},
    );

    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map(
          (item) =>
              FriendRequestApiModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<FriendRequestApiModel>> getOutgoing({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.outgoingFriendRequests,
      queryParameters: {'page': page, 'size': size},
    );

    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map(
          (item) =>
              FriendRequestApiModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
