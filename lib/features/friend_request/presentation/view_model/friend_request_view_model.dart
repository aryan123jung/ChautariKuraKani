import 'package:chautari_kurakani/features/friend_request/domain/usecases/friend_request_actions_usecase.dart';
import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';
import 'package:chautari_kurakani/features/friend_request/domain/usecases/get_friend_status_usecase.dart';
import 'package:chautari_kurakani/features/friend_request/presentation/state/friend_request_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendRequestViewModelProvider =
    NotifierProvider<FriendRequestViewModel, FriendRequestState>(
      FriendRequestViewModel.new,
    );

class FriendRequestViewModel extends Notifier<FriendRequestState> {
  late final SendFriendRequestUsecase _sendFriendRequestUsecase;
  late final CancelFriendRequestUsecase _cancelFriendRequestUsecase;
  late final AcceptFriendRequestUsecase _acceptFriendRequestUsecase;
  late final RejectFriendRequestUsecase _rejectFriendRequestUsecase;
  late final UnfriendUsecase _unfriendUsecase;
  late final GetFriendStatusUsecase _getFriendStatusUsecase;
  late final ListIncomingFriendRequestsUsecase _listIncomingUsecase;
  late final ListOutgoingFriendRequestsUsecase _listOutgoingUsecase;

  @override
  FriendRequestState build() {
    _sendFriendRequestUsecase = ref.read(sendFriendRequestUsecaseProvider);
    _cancelFriendRequestUsecase = ref.read(cancelFriendRequestUsecaseProvider);
    _acceptFriendRequestUsecase = ref.read(acceptFriendRequestUsecaseProvider);
    _rejectFriendRequestUsecase = ref.read(rejectFriendRequestUsecaseProvider);
    _unfriendUsecase = ref.read(unfriendUsecaseProvider);
    _getFriendStatusUsecase = ref.read(getFriendStatusUsecaseProvider);
    _listIncomingUsecase = ref.read(listIncomingFriendRequestsUsecaseProvider);
    _listOutgoingUsecase = ref.read(listOutgoingFriendRequestsUsecaseProvider);
    return const FriendRequestState.initial();
  }

  Future<void> loadStatus(String userId) async {
    final normalizedUserId = userId.trim().toLowerCase();
    final isSameTarget = state.statusUserId == normalizedUserId;
    state = state.copyWith(
      status: FriendRequestStatusUi.loading,
      clearFriendStatus: !isSameTarget,
      statusUserId: normalizedUserId,
      errorMessage: null,
    );
    final result = await _getFriendStatusUsecase(GetFriendStatusParams(userId));

    result.fold(
      (failure) {
        state = state.copyWith(
          status: FriendRequestStatusUi.error,
          clearFriendStatus: true,
          statusUserId: normalizedUserId,
          errorMessage: failure.message,
        );
      },
      (friendStatus) {
        state = state.copyWith(
          status: FriendRequestStatusUi.loaded,
          friendStatus: friendStatus,
          statusUserId: normalizedUserId,
          errorMessage: null,
        );
      },
    );
  }

  Future<bool> sendRequest(String userId) async {
    state = state.copyWith(
      status: FriendRequestStatusUi.submitting,
      errorMessage: null,
    );

    final result = await _sendFriendRequestUsecase(
      SendFriendRequestParams(userId),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: FriendRequestStatusUi.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (request) {
        final exists = state.outgoing.any((item) => item.id == request.id);
        final nextOutgoing = exists
            ? state.outgoing
            : [request, ...state.outgoing];
        state = state.copyWith(
          status: FriendRequestStatusUi.success,
          friendStatus: const FriendStatusEntity(status: 'PENDING_OUTGOING'),
          outgoing: nextOutgoing,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> cancelRequest(String userId) async {
    state = state.copyWith(
      status: FriendRequestStatusUi.submitting,
      errorMessage: null,
    );

    final result = await _cancelFriendRequestUsecase(
      CancelFriendRequestParams(userId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: FriendRequestStatusUi.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final targetId = userId.trim().toLowerCase();
        final nextOutgoing = state.outgoing
            .where((item) => item.toUser.id.trim().toLowerCase() != targetId)
            .toList();
        state = state.copyWith(
          status: FriendRequestStatusUi.success,
          friendStatus: const FriendStatusEntity(status: 'NONE'),
          outgoing: nextOutgoing,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> acceptRequest(String requestId) async {
    state = state.copyWith(
      status: FriendRequestStatusUi.submitting,
      errorMessage: null,
    );

    final result = await _acceptFriendRequestUsecase(
      RespondFriendRequestParams(requestId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: FriendRequestStatusUi.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (request) {
        final normalizedRequestId = requestId.trim().toLowerCase();
        final nextIncoming = state.incoming
            .where(
              (item) => item.id.trim().toLowerCase() != normalizedRequestId,
            )
            .toList();
        final existsOutgoing = state.outgoing.any(
          (item) =>
              item.id.trim().toLowerCase() == request.id.trim().toLowerCase(),
        );
        final nextOutgoing = existsOutgoing
            ? state.outgoing
            : [request, ...state.outgoing];
        state = state.copyWith(
          status: FriendRequestStatusUi.success,
          friendStatus: const FriendStatusEntity(status: 'FRIEND'),
          incoming: nextIncoming,
          outgoing: nextOutgoing,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> rejectRequest(String requestId) async {
    state = state.copyWith(
      status: FriendRequestStatusUi.submitting,
      errorMessage: null,
    );

    final result = await _rejectFriendRequestUsecase(
      RespondFriendRequestParams(requestId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: FriendRequestStatusUi.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final normalizedRequestId = requestId.trim().toLowerCase();
        final nextIncoming = state.incoming
            .where(
              (item) => item.id.trim().toLowerCase() != normalizedRequestId,
            )
            .toList();
        state = state.copyWith(
          status: FriendRequestStatusUi.success,
          friendStatus: const FriendStatusEntity(status: 'NONE'),
          incoming: nextIncoming,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> unfriend(String userId) async {
    state = state.copyWith(
      status: FriendRequestStatusUi.submitting,
      errorMessage: null,
    );

    final result = await _unfriendUsecase(UnfriendParams(userId));
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: FriendRequestStatusUi.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final targetId = userId.trim().toLowerCase();
        final nextOutgoing = state.outgoing
            .where((item) => item.toUser.id.trim().toLowerCase() != targetId)
            .toList();
        state = state.copyWith(
          status: FriendRequestStatusUi.success,
          friendStatus: const FriendStatusEntity(status: 'NONE'),
          outgoing: nextOutgoing,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<void> loadIncoming({int page = 1, int size = 10}) async {
    final result = await _listIncomingUsecase(
      ListFriendRequestsParams(page: page, size: size),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: FriendRequestStatusUi.error,
          errorMessage: failure.message,
        );
      },
      (incoming) {
        state = state.copyWith(
          status: FriendRequestStatusUi.loaded,
          incoming: incoming,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> loadOutgoing({int page = 1, int size = 10}) async {
    final result = await _listOutgoingUsecase(
      ListFriendRequestsParams(page: page, size: size),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: FriendRequestStatusUi.error,
          errorMessage: failure.message,
        );
      },
      (outgoing) {
        state = state.copyWith(
          status: FriendRequestStatusUi.loaded,
          outgoing: outgoing,
          errorMessage: null,
        );
      },
    );
  }
}
