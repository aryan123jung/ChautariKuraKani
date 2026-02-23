import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/features/friend_request/data/datasources/friend_request_datasource.dart';
import 'package:chautari_kurakani/features/friend_request/data/datasources/remote/friend_request_remote_datasource.dart';
import 'package:chautari_kurakani/features/friend_request/domain/entities/friend_request_entity.dart';
import 'package:chautari_kurakani/features/friend_request/domain/repositories/friend_request_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendRequestRepositoryProvider = Provider<IFriendRequestRepository>((
  ref,
) {
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

  final Map<String, _CachedFriendStatus> _statusCache = {};
  final Map<String, _CachedFriendCount> _countCache = {};
  static const Duration _statusCacheTtl = Duration(minutes: 5);

  FriendStatusEntity? _readCachedStatus(String userId) {
    final key = userId.trim().toLowerCase();
    final cached = _statusCache[key];
    if (cached == null) return null;
    final isExpired =
        DateTime.now().difference(cached.cachedAt) > _statusCacheTtl;
    if (isExpired) {
      _statusCache.remove(key);
      return null;
    }
    return cached.value;
  }

  void _writeCachedStatus(String userId, FriendStatusEntity value) {
    final key = userId.trim().toLowerCase();
    if (key.isEmpty) return;
    _statusCache[key] = _CachedFriendStatus(value, DateTime.now());
  }

  void _clearStatusCache() {
    _statusCache.clear();
    _countCache.clear();
  }

  int? _readCachedCount(String userId) {
    final key = userId.trim().toLowerCase();
    final cached = _countCache[key];
    if (cached == null) return null;
    final isExpired =
        DateTime.now().difference(cached.cachedAt) > _statusCacheTtl;
    if (isExpired) {
      _countCache.remove(key);
      return null;
    }
    return cached.value;
  }

  void _writeCachedCount(String userId, int value) {
    final key = userId.trim().toLowerCase();
    if (key.isEmpty) return;
    _countCache[key] = _CachedFriendCount(value, DateTime.now());
  }

  @override
  Future<Either<Failure, FriendRequestEntity>> sendRequest(
    String toUserId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final request = await _remoteDatasource.sendRequest(toUserId);
      _clearStatusCache();
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
      _clearStatusCache();
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
  Future<Either<Failure, FriendRequestEntity>> acceptRequest(
    String requestId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final request = await _remoteDatasource.acceptRequest(requestId);
      _clearStatusCache();
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
  Future<Either<Failure, FriendRequestEntity>> rejectRequest(
    String requestId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final request = await _remoteDatasource.rejectRequest(requestId);
      _clearStatusCache();
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
      _clearStatusCache();
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
    final cached = _readCachedStatus(userId);
    if (cached != null) {
      return Right(cached);
    }

    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final status = await _remoteDatasource.getStatus(userId);
      final entity = status.toEntity();
      _writeCachedStatus(userId, entity);
      return Right(entity);
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
  Future<Either<Failure, int>> getFriendCount(String userId) async {
    final cached = _readCachedCount(userId);
    if (cached != null) {
      return Right(cached);
    }

    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final count = await _remoteDatasource.getFriendCount(userId);
      _writeCachedCount(userId, count);
      return Right(count);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch friend count',
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
      final requests = await _remoteDatasource.getIncoming(
        page: page,
        size: size,
      );
      return Right(requests.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ??
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
      final requests = await _remoteDatasource.getOutgoing(
        page: page,
        size: size,
      );
      return Right(requests.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ??
              'Failed to fetch outgoing requests',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

class _CachedFriendStatus {
  final FriendStatusEntity value;
  final DateTime cachedAt;

  const _CachedFriendStatus(this.value, this.cachedAt);
}

class _CachedFriendCount {
  final int value;
  final DateTime cachedAt;

  const _CachedFriendCount(this.value, this.cachedAt);
}
