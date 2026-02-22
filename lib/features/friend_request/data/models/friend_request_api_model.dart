import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';

class FriendUserApiModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileUrl;

  const FriendUserApiModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profileUrl,
  });

  factory FriendUserApiModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final rawProfile = json['profileUrl']?.toString();
      return FriendUserApiModel(
        id: json['_id']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        profileUrl: _resolveProfileUrl(rawProfile),
      );
    }

    final id = json?.toString() ?? '';
    return FriendUserApiModel(
      id: id,
      firstName: '',
      lastName: '',
      username: '',
      profileUrl: null,
    );
  }

  FriendUserEntity toEntity() {
    return FriendUserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      profileUrl: profileUrl,
    );
  }

  static String? _resolveProfileUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http')) return value;
    if (value.contains('/') || value.contains('\\')) {
      return ApiEndpoints.uploadUrl(value);
    }
    return ApiEndpoints.profileImageUrl(value);
  }
}

class FriendRequestApiModel {
  final String id;
  final FriendUserApiModel fromUser;
  final FriendUserApiModel toUser;
  final String status;
  final DateTime? createdAt;

  const FriendRequestApiModel({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.status,
    this.createdAt,
  });

  factory FriendRequestApiModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestApiModel(
      id: json['_id']?.toString() ?? '',
      fromUser: FriendUserApiModel.fromJson(json['fromUserId']),
      toUser: FriendUserApiModel.fromJson(json['toUserId']),
      status: json['status']?.toString() ?? 'NONE',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  FriendRequestEntity toEntity() {
    return FriendRequestEntity(
      id: id,
      fromUser: fromUser.toEntity(),
      toUser: toUser.toEntity(),
      status: status,
      createdAt: createdAt,
    );
  }
}

class FriendStatusApiModel {
  final String status;
  final String? requestId;

  const FriendStatusApiModel({required this.status, this.requestId});

  factory FriendStatusApiModel.fromJson(Map<String, dynamic> json) {
    return FriendStatusApiModel(
      status: json['status']?.toString() ?? 'NONE',
      requestId: json['requestId']?.toString(),
    );
  }

  FriendStatusEntity toEntity() {
    return FriendStatusEntity(status: status, requestId: requestId);
  }
}
