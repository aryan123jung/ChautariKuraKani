import 'package:equatable/equatable.dart';

class FriendUserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileUrl;

  const FriendUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profileUrl,
  });

  String get fullName =>
      [firstName, lastName].where((part) => part.trim().isNotEmpty).join(' ');

  @override
  List<Object?> get props => [id, firstName, lastName, username, profileUrl];
}

class FriendRequestEntity extends Equatable {
  final String id;
  final FriendUserEntity fromUser;
  final FriendUserEntity toUser;
  final String status;
  final DateTime? createdAt;

  const FriendRequestEntity({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.status,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, fromUser, toUser, status, createdAt];
}

class FriendStatusEntity extends Equatable {
  final String status;
  final String? requestId;

  const FriendStatusEntity({required this.status, this.requestId});

  @override
  List<Object?> get props => [status, requestId];
}
