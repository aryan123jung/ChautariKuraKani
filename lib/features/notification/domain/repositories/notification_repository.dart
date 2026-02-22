import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/notification/domain/entities/notification_entity.dart';
import 'package:dartz/dartz.dart';

abstract class INotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int size = 20,
  });
  Future<Either<Failure, NotificationEntity>> markRead(String id);
  Future<Either<Failure, bool>> markAllRead();
}
