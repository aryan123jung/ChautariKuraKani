import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IFriendRequestRepository {
  Future<Either<Failure, FriendRequestEntity>> sendRequest(String toUserId);
  Future<Either<Failure, bool>> cancelRequest(String toUserId);
  Future<Either<Failure, FriendRequestEntity>> acceptRequest(String requestId);
  Future<Either<Failure, FriendRequestEntity>> rejectRequest(String requestId);
  Future<Either<Failure, bool>> unfriend(String friendUserId);
  Future<Either<Failure, FriendStatusEntity>> getStatus(String userId);
  Future<Either<Failure, int>> getFriendCount(String userId);
  Future<Either<Failure, List<FriendRequestEntity>>> getIncoming({
    int page = 1,
    int size = 10,
  });
  Future<Either<Failure, List<FriendRequestEntity>>> getOutgoing({
    int page = 1,
    int size = 10,
  });
}
