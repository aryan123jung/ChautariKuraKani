import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/features/notification/data/datasources/notification_datasource.dart';
import 'package:chautari_kurakani/features/notification/data/datasources/remote/notification_remote_datasource.dart';
import 'package:chautari_kurakani/features/notification/domain/entities/notification_entity.dart';
import 'package:chautari_kurakani/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepository(
    remoteDatasource: ref.read(notificationRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class NotificationRepository implements INotificationRepository {
  final INotificationRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  NotificationRepository({
    required INotificationRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int size = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final items = await _remoteDatasource.getNotifications(page: page, size: size);
      return Right(items.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch notifications',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markRead(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final item = await _remoteDatasource.markRead(id);
      return Right(item.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to mark as read',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllRead() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      await _remoteDatasource.markAllRead();
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to mark all as read',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
