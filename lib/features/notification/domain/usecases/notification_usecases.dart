import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/notification/data/repositories/notification_repository.dart';
import 'package:chautari_kurakani/features/notification/domain/entities/notification_entity.dart';
import 'package:chautari_kurakani/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetNotificationsParams extends Equatable {
  final int page;
  final int size;

  const GetNotificationsParams({this.page = 1, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}

class MarkNotificationReadParams extends Equatable {
  final String id;
  const MarkNotificationReadParams(this.id);

  @override
  List<Object?> get props => [id];
}

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>((ref) {
  return GetNotificationsUsecase(repository: ref.read(notificationRepositoryProvider));
});

final markNotificationReadUsecaseProvider = Provider<MarkNotificationReadUsecase>((
  ref,
) {
  return MarkNotificationReadUsecase(
    repository: ref.read(notificationRepositoryProvider),
  );
});

final markAllNotificationsReadUsecaseProvider =
    Provider<MarkAllNotificationsReadUsecase>((ref) {
      return MarkAllNotificationsReadUsecase(
        repository: ref.read(notificationRepositoryProvider),
      );
    });

class GetNotificationsUsecase
    implements UsecaseWithParams<List<NotificationEntity>, GetNotificationsParams> {
  final INotificationRepository _repository;

  GetNotificationsUsecase({required INotificationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) {
    return _repository.getNotifications(page: params.page, size: params.size);
  }
}

class MarkNotificationReadUsecase
    implements UsecaseWithParams<NotificationEntity, MarkNotificationReadParams> {
  final INotificationRepository _repository;

  MarkNotificationReadUsecase({required INotificationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, NotificationEntity>> call(
    MarkNotificationReadParams params,
  ) {
    return _repository.markRead(params.id);
  }
}

class MarkAllNotificationsReadUsecase
    implements UsecaseWithoutParams<bool> {
  final INotificationRepository _repository;

  MarkAllNotificationsReadUsecase({required INotificationRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call() {
    return _repository.markAllRead();
  }
}
