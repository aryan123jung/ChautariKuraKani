import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/core/services/hive/app_cache_service.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/call/data/datasources/call_datasource.dart';
import 'package:chautari_kurakani/features/call/data/datasources/remote/call_remote_datasource.dart';
import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:chautari_kurakani/features/call/domain/repositories/call_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final callRepositoryProvider = Provider<ICallRepository>((ref) {
  return CallRepository(
    remoteDatasource: ref.read(callRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cacheService: ref.read(appCacheServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class CallRepository implements ICallRepository {
  final ICallRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;
  final AppCacheService _cacheService;
  final UserSessionService _userSessionService;
  static const _callHistoryTtl = Duration(seconds: 45);

  CallRepository({
    required ICallRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
    required AppCacheService cacheService,
    required UserSessionService userSessionService,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo,
       _cacheService = cacheService,
       _userSessionService = userSessionService;

  String _callsKey(int page, int size) {
    final userId = (_userSessionService.getCurrentUserId() ?? '')
        .trim()
        .toLowerCase();
    return 'call_history_${userId}_${page}_$size';
  }

  List<CallLogEntity>? _readCallsCache(int page, int size, {Duration? maxAge}) {
    return _cacheService.read<List<CallLogEntity>>(
      key: _callsKey(page, size),
      maxAge: maxAge,
      decoder: (raw) {
        final list = (raw as List).cast<dynamic>();
        return list
            .map((item) {
              final map = (item as Map).cast<String, dynamic>();
              CallUserEntity? decodeUser(dynamic userRaw) {
                if (userRaw is! Map) return null;
                final userMap = userRaw.cast<String, dynamic>();
                return CallUserEntity(
                  id: userMap['id']?.toString() ?? '',
                  firstName: userMap['firstName']?.toString() ?? '',
                  lastName: userMap['lastName']?.toString() ?? '',
                  username: userMap['username']?.toString() ?? '',
                  profileUrl: userMap['profileUrl']?.toString(),
                );
              }

              return CallLogEntity(
                id: map['id']?.toString() ?? '',
                caller: decodeUser(map['caller']),
                callee: decodeUser(map['callee']),
                callerId: map['callerId']?.toString() ?? '',
                calleeId: map['calleeId']?.toString() ?? '',
                status: _decodeStatus(map['status']?.toString()),
                callType: _decodeType(map['callType']?.toString()),
                startedAt: DateTime.tryParse(
                  map['startedAt']?.toString() ?? '',
                ),
                endedAt: DateTime.tryParse(map['endedAt']?.toString() ?? ''),
                durationSeconds: (map['durationSeconds'] is int)
                    ? map['durationSeconds'] as int
                    : int.tryParse(map['durationSeconds']?.toString() ?? ''),
                createdAt: DateTime.tryParse(
                  map['createdAt']?.toString() ?? '',
                ),
              );
            })
            .toList(growable: false);
      },
    );
  }

  Future<void> _writeCallsCache(
    List<CallLogEntity> calls,
    int page,
    int size,
  ) async {
    Map<String, dynamic>? encodeUser(CallUserEntity? user) {
      if (user == null) return null;
      return {
        'id': user.id,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'username': user.username,
        'profileUrl': user.profileUrl,
      };
    }

    final payload = calls
        .map(
          (call) => {
            'id': call.id,
            'caller': encodeUser(call.caller),
            'callee': encodeUser(call.callee),
            'callerId': call.callerId,
            'calleeId': call.calleeId,
            'status': call.status.name,
            'callType': call.callType.name,
            'startedAt': call.startedAt?.toIso8601String(),
            'endedAt': call.endedAt?.toIso8601String(),
            'durationSeconds': call.durationSeconds,
            'createdAt': call.createdAt?.toIso8601String(),
          },
        )
        .toList(growable: false);

    await _cacheService.write(key: _callsKey(page, size), data: payload);
  }

  Future<List<CallLogEntity>> _fetchRemoteCalls({
    required int page,
    required int size,
  }) async {
    final calls = await _remoteDatasource.listMyCalls(page: page, size: size);
    final entities = calls.map((item) => item.toEntity()).toList();
    if (page == 1) {
      await _writeCallsCache(entities, page, size);
    }
    return entities;
  }

  CallStatusEntity _decodeStatus(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'accepted':
        return CallStatusEntity.accepted;
      case 'rejected':
        return CallStatusEntity.rejected;
      case 'missed':
        return CallStatusEntity.missed;
      case 'ended':
        return CallStatusEntity.ended;
      default:
        return CallStatusEntity.ringing;
    }
  }

  CallTypeEntity _decodeType(String? raw) {
    return (raw ?? '').toLowerCase() == 'video'
        ? CallTypeEntity.video
        : CallTypeEntity.audio;
  }

  @override
  Future<Either<Failure, List<CallLogEntity>>> listMyCalls({
    int page = 1,
    int size = 20,
    bool bypassCache = false,
  }) async {
    final isFirstPage = page == 1;
    final cached = isFirstPage
        ? _readCallsCache(page, size, maxAge: _callHistoryTtl)
        : null;
    if (!bypassCache && cached != null) {
      return Right(cached);
    }

    if (!await _networkInfo.isConnected) {
      final stale = !bypassCache && isFirstPage
          ? _readCallsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final entities = await _fetchRemoteCalls(page: page, size: size);
      return Right(entities);
    } on DioException catch (e) {
      final stale = !bypassCache && isFirstPage
          ? _readCallsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch call history',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      final stale = !bypassCache && isFirstPage
          ? _readCallsCache(page, size)
          : null;
      if (stale != null) return Right(stale);
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
