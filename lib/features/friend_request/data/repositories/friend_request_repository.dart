import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/core/services/hive/app_cache_service.dart';
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
    cacheService: ref.read(appCacheServiceProvider),
  );
});

class FriendRequestRepository implements IFriendRequestRepository {
  final IFriendRequestRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;
  final AppCacheService _cacheService;

  FriendRequestRepository({
    required IFriendRequestRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
    required AppCacheService cacheService,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo,
       _cacheService = cacheService;

  final Map<String, _CachedFriendStatus> _statusCache = {};
  final Map<String, _CachedFriendCount> _countCache = {};

  String _statusKey(String userId) =>
      'friend_status_${userId.trim().toLowerCase()}';
  String _countKey(String userId) =>
      'friend_count_${userId.trim().toLowerCase()}';

  void _writeCachedStatus(String userId, FriendStatusEntity value) {
    final key = userId.trim().toLowerCase();
    if (key.isEmpty) return;
    final now = DateTime.now();
    _statusCache[key] = _CachedFriendStatus(value, now);
    _cacheService.write(
      key: _statusKey(userId),
      data: {'status': value.status, 'requestId': value.requestId},
    );
  }

  void _clearStatusCache() {
    _statusCache.clear();
    _countCache.clear();
    _cacheService.clearByPrefix('friend_status_');
    _cacheService.clearByPrefix('friend_count_');
  }

  void _writeCachedCount(String userId, int value) {
    final key = userId.trim().toLowerCase();
    if (key.isEmpty) return;
    final now = DateTime.now();
    _countCache[key] = _CachedFriendCount(value, now);
    _cacheService.write(key: _countKey(userId), data: {'count': value});
  }

  FriendStatusEntity? _readCachedStatus(String userId, {Duration? maxAge}) {
    final key = userId.trim().toLowerCase();
    if (key.isEmpty) return null;
    final memory = _statusCache[key];
    if (memory != null &&
        (maxAge == null ||
            DateTime.now().difference(memory.cachedAt) <= maxAge)) {
      return memory.value;
    }

    final fromHive = _cacheService.read<FriendStatusEntity>(
      key: _statusKey(userId),
      maxAge: maxAge,
      decoder: (raw) {
        final map = (raw as Map).cast<String, dynamic>();
        return FriendStatusEntity(
          status: map['status']?.toString() ?? 'NONE',
          requestId: map['requestId']?.toString(),
        );
      },
    );
    if (fromHive != null) {
      _statusCache[key] = _CachedFriendStatus(fromHive, DateTime.now());
    }
    return fromHive;
  }

  int? _readCachedCount(String userId, {Duration? maxAge}) {
    final key = userId.trim().toLowerCase();
    if (key.isEmpty) return null;
    final memory = _countCache[key];
    if (memory != null &&
        (maxAge == null ||
            DateTime.now().difference(memory.cachedAt) <= maxAge)) {
      return memory.value;
    }

    final fromHive = _cacheService.read<int>(
      key: _countKey(userId),
      maxAge: maxAge,
      decoder: (raw) {
        final map = (raw as Map).cast<String, dynamic>();
        final countRaw = map['count'];
        if (countRaw is int) return countRaw;
        return int.tryParse(countRaw?.toString() ?? '0') ?? 0;
      },
    );
    if (fromHive != null) {
      _countCache[key] = _CachedFriendCount(fromHive, DateTime.now());
    }
    return fromHive;
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
    if (!await _networkInfo.isConnected) {
      final cached = _readCachedStatus(userId);
      if (cached != null) return Right(cached);
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final status = await _remoteDatasource.getStatus(userId);
      final entity = status.toEntity();
      _writeCachedStatus(userId, entity);
      return Right(entity);
    } on DioException catch (e) {
      final cached = _readCachedStatus(userId);
      if (cached != null) return Right(cached);
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch status',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      final cached = _readCachedStatus(userId);
      if (cached != null) return Right(cached);
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getFriendCount(String userId) async {
    if (!await _networkInfo.isConnected) {
      final cached = _readCachedCount(userId);
      if (cached != null) return Right(cached);
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final count = await _remoteDatasource.getFriendCount(userId);
      _writeCachedCount(userId, count);
      return Right(count);
    } on DioException catch (e) {
      final cached = _readCachedCount(userId);
      if (cached != null) return Right(cached);
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch friend count',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      final cached = _readCachedCount(userId);
      if (cached != null) return Right(cached);
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
