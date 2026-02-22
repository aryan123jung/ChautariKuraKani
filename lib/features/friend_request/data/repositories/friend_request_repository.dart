import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/features/friend_request/data/datasources/friend_request_datasource.dart';
import 'package:chautari_kurakani/features/friend_request/data/datasources/remote/friend_request_remote_datasource.dart';
import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';
import 'package:chautari_kurakani/features/friend_request/domain/repositories/friend_request_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendRequestRepositoryProvider = Provider<IFriendRequestRepository>((ref) {
  return FriendRequestRepository(
    remoteDatasource: ref.read(friendRequestRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class FriendRequestRepository implements IFriendRequestRepository {
  final IFriendRequestRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  FriendRequestRepository({
    required IFriendRequestRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, FriendRequestEntity>> sendRequest(String toUserId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final request = await _remoteDatasource.sendRequest(toUserId);
      return Right(request.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to send request',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelRequest(String toUserId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      await _remoteDatasource.cancelRequest(toUserId);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to cancel request',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendRequestEntity>> acceptRequest(String requestId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final request = await _remoteDatasource.acceptRequest(requestId);
      return Right(request.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to accept request',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendRequestEntity>> rejectRequest(String requestId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final request = await _remoteDatasource.rejectRequest(requestId);
      return Right(request.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to reject request',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unfriend(String friendUserId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      await _remoteDatasource.unfriend(friendUserId);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to unfriend',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendStatusEntity>> getStatus(String userId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final status = await _remoteDatasource.getStatus(userId);
      return Right(status.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch status',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequestEntity>>> getIncoming({
    int page = 1,
    int size = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final requests = await _remoteDatasource.getIncoming(page: page, size: size);
      return Right(requests.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ??
              'Failed to fetch incoming requests',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequestEntity>>> getOutgoing({
    int page = 1,
    int size = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final requests = await _remoteDatasource.getOutgoing(page: page, size: size);
      return Right(requests.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ??
              'Failed to fetch outgoing requests',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
