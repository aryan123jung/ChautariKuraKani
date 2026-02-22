import 'package:chautari_kurakani/features/notification/data/models/notification_api_model.dart';

abstract class INotificationRemoteDatasource {
  Future<List<NotificationApiModel>> getNotifications({
    int page = 1,
    int size = 20,
  });
  Future<NotificationApiModel> markRead(String id);
  Future<void> markAllRead();
}
