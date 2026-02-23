import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';
import 'package:equatable/equatable.dart';

enum FriendRequestStatusUi { initial, loading, loaded, submitting, success, error }

class FriendRequestState extends Equatable {
  final FriendRequestStatusUi status;
  final FriendStatusEntity? friendStatus;
  final String? statusUserId;
  final List<FriendRequestEntity> incoming;
  final List<FriendRequestEntity> outgoing;
  final String? errorMessage;

  const FriendRequestState({
    required this.status,
    this.friendStatus,
    this.statusUserId,
    this.incoming = const [],
    this.outgoing = const [],
    this.errorMessage,
  });

  const FriendRequestState.initial()
    : status = FriendRequestStatusUi.initial,
      friendStatus = null,
      statusUserId = null,
      incoming = const [],
      outgoing = const [],
      errorMessage = null;

  FriendRequestState copyWith({
    FriendRequestStatusUi? status,
    FriendStatusEntity? friendStatus,
    bool clearFriendStatus = false,
    String? statusUserId,
    bool clearStatusUserId = false,
    List<FriendRequestEntity>? incoming,
    List<FriendRequestEntity>? outgoing,
    String? errorMessage,
  }) {
    return FriendRequestState(
      status: status ?? this.status,
      friendStatus: clearFriendStatus
          ? null
          : friendStatus ?? this.friendStatus,
      statusUserId: clearStatusUserId
          ? null
          : statusUserId ?? this.statusUserId,
      incoming: incoming ?? this.incoming,
      outgoing: outgoing ?? this.outgoing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    friendStatus,
    statusUserId,
    incoming,
    outgoing,
    errorMessage,
  ];
}
