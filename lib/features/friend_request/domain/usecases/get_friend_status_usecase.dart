import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/friend_request/data/repositories/friend_request_repository.dart';
import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';
import 'package:chautari_kurakani/features/friend_request/domain/repositories/friend_request_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetFriendStatusParams extends Equatable {
  final String userId;

  const GetFriendStatusParams(this.userId);

  @override
  List<Object?> get props => [userId];
}

final getFriendStatusUsecaseProvider = Provider<GetFriendStatusUsecase>((ref) {
  return GetFriendStatusUsecase(repository: ref.read(friendRequestRepositoryProvider));
});

class GetFriendStatusUsecase
    implements UsecaseWithParams<FriendStatusEntity, GetFriendStatusParams> {
  final IFriendRequestRepository _repository;

  GetFriendStatusUsecase({required IFriendRequestRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, FriendStatusEntity>> call(GetFriendStatusParams params) {
    return _repository.getStatus(params.userId);
  }
}
