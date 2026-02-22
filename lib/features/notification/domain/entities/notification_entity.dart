import 'package:equatable/equatable.dart';

class NotificationActorEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileUrl;

  const NotificationActorEntity({
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

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final NotificationActorEntity actor;
  final String type;
  final String entityType;
  final String entityId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationEntity({
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

  String get relativeTime {
    if (createdAt == null) return 'just now';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      userId: userId,
      actor: actor,
      type: type,
      entityType: entityType,
      entityId: entityId,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    actor,
    type,
    entityType,
    entityId,
    title,
    message,
    isRead,
    createdAt,
  ];
}
