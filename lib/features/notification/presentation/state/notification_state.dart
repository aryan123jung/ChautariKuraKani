import 'package:chautari_kurakani/features/notification/domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';

enum NotificationStatusUi { initial, loading, loaded, error, submitting }

class NotificationState extends Equatable {
  final NotificationStatusUi status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const NotificationState({
    required this.status,
    this.notifications = const [],
    this.errorMessage,
  });

  const NotificationState.initial()
    : status = NotificationStatusUi.initial,
      notifications = const [],
      errorMessage = null;

  NotificationState copyWith({
    NotificationStatusUi? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }

  int get unreadCount => notifications.where((item) => !item.isRead).length;

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}
