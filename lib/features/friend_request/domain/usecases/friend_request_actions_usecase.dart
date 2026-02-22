import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/friend_request/data/repositories/friend_request_repository.dart';
import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';
import 'package:chautari_kurakani/features/friend_request/domain/repositories/friend_request_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendFriendRequestParams extends Equatable {
  final String toUserId;
  const SendFriendRequestParams(this.toUserId);
  @override
  List<Object?> get props => [toUserId];
}

class CancelFriendRequestParams extends Equatable {
  final String toUserId;
  const CancelFriendRequestParams(this.toUserId);
  @override
  List<Object?> get props => [toUserId];
}

class RespondFriendRequestParams extends Equatable {
  final String requestId;
  const RespondFriendRequestParams(this.requestId);
  @override
  List<Object?> get props => [requestId];
}

class UnfriendParams extends Equatable {
  final String friendUserId;
  const UnfriendParams(this.friendUserId);
  @override
  List<Object?> get props => [friendUserId];
}

class ListFriendRequestsParams extends Equatable {
  final int page;
  final int size;
  const ListFriendRequestsParams({this.page = 1, this.size = 10});
  @override
  List<Object?> get props => [page, size];
}

final sendFriendRequestUsecaseProvider = Provider<SendFriendRequestUsecase>((
  ref,
) {
  return SendFriendRequestUsecase(
    repository: ref.read(friendRequestRepositoryProvider),
  );
});

final cancelFriendRequestUsecaseProvider = Provider<CancelFriendRequestUsecase>((
  ref,
) {
  return CancelFriendRequestUsecase(
    repository: ref.read(friendRequestRepositoryProvider),
  );
});

final acceptFriendRequestUsecaseProvider = Provider<AcceptFriendRequestUsecase>((
  ref,
) {
  return AcceptFriendRequestUsecase(
    repository: ref.read(friendRequestRepositoryProvider),
  );
});

final rejectFriendRequestUsecaseProvider = Provider<RejectFriendRequestUsecase>((
  ref,
) {
  return RejectFriendRequestUsecase(
    repository: ref.read(friendRequestRepositoryProvider),
  );
});

final unfriendUsecaseProvider = Provider<UnfriendUsecase>((ref) {
  return UnfriendUsecase(repository: ref.read(friendRequestRepositoryProvider));
});

final listIncomingFriendRequestsUsecaseProvider =
    Provider<ListIncomingFriendRequestsUsecase>((ref) {
      return ListIncomingFriendRequestsUsecase(
        repository: ref.read(friendRequestRepositoryProvider),
      );
    });

final listOutgoingFriendRequestsUsecaseProvider =
    Provider<ListOutgoingFriendRequestsUsecase>((ref) {
      return ListOutgoingFriendRequestsUsecase(
        repository: ref.read(friendRequestRepositoryProvider),
      );
    });

class SendFriendRequestUsecase
    implements UsecaseWithParams<FriendRequestEntity, SendFriendRequestParams> {
  final IFriendRequestRepository _repository;
  SendFriendRequestUsecase({required IFriendRequestRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, FriendRequestEntity>> call(
    SendFriendRequestParams params,
  ) {
    return _repository.sendRequest(params.toUserId);
  }
}

class CancelFriendRequestUsecase
    implements UsecaseWithParams<bool, CancelFriendRequestParams> {
  final IFriendRequestRepository _repository;
  CancelFriendRequestUsecase({required IFriendRequestRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(CancelFriendRequestParams params) {
    return _repository.cancelRequest(params.toUserId);
  }
}

class AcceptFriendRequestUsecase
    implements
        UsecaseWithParams<FriendRequestEntity, RespondFriendRequestParams> {
  final IFriendRequestRepository _repository;
  AcceptFriendRequestUsecase({required IFriendRequestRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, FriendRequestEntity>> call(
    RespondFriendRequestParams params,
  ) {
    return _repository.acceptRequest(params.requestId);
  }
}

class RejectFriendRequestUsecase
    implements
        UsecaseWithParams<FriendRequestEntity, RespondFriendRequestParams> {
  final IFriendRequestRepository _repository;
  RejectFriendRequestUsecase({required IFriendRequestRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, FriendRequestEntity>> call(
    RespondFriendRequestParams params,
  ) {
    return _repository.rejectRequest(params.requestId);
  }
}

class UnfriendUsecase implements UsecaseWithParams<bool, UnfriendParams> {
  final IFriendRequestRepository _repository;
  UnfriendUsecase({required IFriendRequestRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(UnfriendParams params) {
    return _repository.unfriend(params.friendUserId);
  }
}

class ListIncomingFriendRequestsUsecase
    implements
        UsecaseWithParams<List<FriendRequestEntity>, ListFriendRequestsParams> {
  final IFriendRequestRepository _repository;
  ListIncomingFriendRequestsUsecase({required IFriendRequestRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<FriendRequestEntity>>> call(
    ListFriendRequestsParams params,
  ) {
    return _repository.getIncoming(page: params.page, size: params.size);
  }
}

class ListOutgoingFriendRequestsUsecase
    implements
        UsecaseWithParams<List<FriendRequestEntity>, ListFriendRequestsParams> {
  final IFriendRequestRepository _repository;
  ListOutgoingFriendRequestsUsecase({required IFriendRequestRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<FriendRequestEntity>>> call(
    ListFriendRequestsParams params,
  ) {
    return _repository.getOutgoing(page: params.page, size: params.size);
  }
}
