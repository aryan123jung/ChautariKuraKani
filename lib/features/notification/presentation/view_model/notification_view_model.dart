import 'dart:async';

import 'package:chautari_kurakani/features/notification/data/services/notification_socket_service.dart';
import 'package:chautari_kurakani/features/notification/domain/entities/notification_entity.dart';
import 'package:chautari_kurakani/features/notification/domain/usecases/notification_usecases.dart';
import 'package:chautari_kurakani/features/notification/presentation/state/notification_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
      NotificationViewModel.new,
    );

class NotificationViewModel extends Notifier<NotificationState> {
  late final GetNotificationsUsecase _getNotificationsUsecase;
  late final MarkNotificationReadUsecase _markNotificationReadUsecase;
  late final MarkAllNotificationsReadUsecase _markAllNotificationsReadUsecase;
  late final NotificationSocketService _socketService;

  StreamSubscription<NotificationEntity>? _socketSubscription;

  @override
  NotificationState build() {
    _getNotificationsUsecase = ref.read(getNotificationsUsecaseProvider);
    _markNotificationReadUsecase = ref.read(markNotificationReadUsecaseProvider);
    _markAllNotificationsReadUsecase = ref.read(
      markAllNotificationsReadUsecaseProvider,
    );
    _socketService = ref.read(notificationSocketServiceProvider);

    ref.onDispose(() {
      _socketSubscription?.cancel();
      _socketService.disconnect();
    });

    return const NotificationState.initial();
  }

  Future<void> fetchNotifications({int page = 1, int size = 20}) async {
    state = state.copyWith(status: NotificationStatusUi.loading, errorMessage: null);

    final result = await _getNotificationsUsecase(
      GetNotificationsParams(page: page, size: size),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationStatusUi.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        state = state.copyWith(
          status: NotificationStatusUi.loaded,
          notifications: items,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> markRead(String id) async {
    final result = await _markNotificationReadUsecase(
      MarkNotificationReadParams(id),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationStatusUi.error,
          errorMessage: failure.message,
        );
      },
      (updated) {
        final next = state.notifications
            .map((item) => item.id == id ? updated : item)
            .toList();
        state = state.copyWith(
          status: NotificationStatusUi.loaded,
          notifications: next,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> markAllRead() async {
    state = state.copyWith(status: NotificationStatusUi.submitting, errorMessage: null);

    final result = await _markAllNotificationsReadUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationStatusUi.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        final next = state.notifications
            .map((item) => item.copyWith(isRead: true))
            .toList();
        state = state.copyWith(
          status: NotificationStatusUi.loaded,
          notifications: next,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> connectRealtime() async {
    await _socketService.connect();
    await _socketSubscription?.cancel();
    _socketSubscription = _socketService.stream.listen((item) {
      final exists = state.notifications.any((element) => element.id == item.id);
      if (exists) return;

      state = state.copyWith(
        status: NotificationStatusUi.loaded,
        notifications: [item, ...state.notifications],
      );
    });
  }

  void disconnectRealtime() {
    _socketSubscription?.cancel();
    _socketSubscription = null;
    _socketService.disconnect();
  }
}
