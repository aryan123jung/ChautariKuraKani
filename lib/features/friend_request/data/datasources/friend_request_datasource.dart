import 'package:chautari_kurakani/features/friend_request/data/models/friend_request_api_model.dart';

abstract class IFriendRequestRemoteDatasource {
  Future<FriendRequestApiModel> sendRequest(String toUserId);
  Future<void> cancelRequest(String toUserId);
  Future<FriendRequestApiModel> acceptRequest(String requestId);
  Future<FriendRequestApiModel> rejectRequest(String requestId);
  Future<void> unfriend(String friendUserId);
  Future<FriendStatusApiModel> getStatus(String userId);
  Future<int> getFriendCount(String userId);
  Future<List<FriendRequestApiModel>> getIncoming({
    int page = 1,
    int size = 10,
  });
  Future<List<FriendRequestApiModel>> getOutgoing({
    int page = 1,
    int size = 10,
  });
}
