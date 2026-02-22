import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/notification/domain/entities/notification_entity.dart';

class NotificationActorApiModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileUrl;

  const NotificationActorApiModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profileUrl,
  });

  factory NotificationActorApiModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final rawProfile = json['profileUrl']?.toString();
      return NotificationActorApiModel(
        id: json['_id']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        profileUrl: _resolveProfileUrl(rawProfile),
      );
    }

    return const NotificationActorApiModel(
      id: '',
      firstName: '',
      lastName: '',
      username: '',
      profileUrl: null,
    );
  }

  NotificationActorEntity toEntity() {
    return NotificationActorEntity(
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

class NotificationApiModel {
  final String id;
  final String userId;
  final NotificationActorApiModel actor;
  final String type;
  final String entityType;
  final String entityId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationApiModel({
    required this.id,
    required this.userId,
    required this.actor,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    final dynamic actorRaw = json['actorUserId'];
    final dynamic userRaw = json['userId'];

    return NotificationApiModel(
      id: json['_id']?.toString() ?? '',
      userId: userRaw is Map<String, dynamic>
          ? (userRaw['_id']?.toString() ?? '')
          : userRaw?.toString() ?? '',
      actor: NotificationActorApiModel.fromJson(actorRaw),
      type: json['type']?.toString() ?? '',
      entityType: json['entityType']?.toString() ?? '',
      entityId: json['entityId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      actor: actor.toEntity(),
      type: type,
      entityType: entityType,
      entityId: entityId,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}
