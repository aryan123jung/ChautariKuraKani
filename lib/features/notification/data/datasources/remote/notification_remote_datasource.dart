import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/notification/data/datasources/notification_datasource.dart';
import 'package:chautari_kurakani/features/notification/data/models/notification_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRemoteDatasourceProvider =
    Provider<INotificationRemoteDatasource>((ref) {
      return NotificationRemoteDatasource(apiClient: ref.read(apiClientProvider));
    });

class NotificationRemoteDatasource implements INotificationRemoteDatasource {
  final ApiClient _apiClient;

  NotificationRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<NotificationApiModel>> getNotifications({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'size': size},
    );

    final raw = response.data['data'] as List<dynamic>? ?? [];
    return raw
        .map((item) => NotificationApiModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NotificationApiModel> markRead(String id) async {
    final response = await _apiClient.patch(ApiEndpoints.markNotificationRead(id));
    return NotificationApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> markAllRead() async {
    await _apiClient.patch(ApiEndpoints.markAllNotificationsRead);
  }
}
