import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/core/services/hive/app_cache_service.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/chautari/data/datasources/chautari_datasource.dart';
import 'package:chautari_kurakani/features/chautari/data/datasources/remote/chautari_remote_datasource.dart';
import 'package:chautari_kurakani/features/chautari/domain/entities/chautari_entity.dart';
import 'package:chautari_kurakani/features/chautari/domain/repositories/chautari_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chautariRepositoryProvider = Provider<IChautariRepository>((ref) {
  return ChautariRepository(
    remoteDatasource: ref.read(chautariRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cacheService: ref.read(appCacheServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class ChautariRepository implements IChautariRepository {
  final IChautariRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;
  final AppCacheService _cacheService;
  final UserSessionService _userSessionService;

  ChautariRepository({
    required IChautariRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
    required AppCacheService cacheService,
    required UserSessionService userSessionService,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo,
       _cacheService = cacheService,
       _userSessionService = userSessionService;

  static const _myChautariTtl = Duration(minutes: 2);

  String _myChautariKey(int page, int size) {
    final userId = (_userSessionService.getCurrentUserId() ?? '')
        .trim()
        .toLowerCase();
    return 'my_chautari_${userId}_${page}_$size';
  }

  String _countKey(String userId) =>
      'chautari_count_${userId.trim().toLowerCase()}';

  Future<void> _clearMembershipCaches() async {
    final userId = (_userSessionService.getCurrentUserId() ?? '')
        .trim()
        .toLowerCase();
    await _cacheService.clearByPrefix('my_chautari_${userId}_');
    await _cacheService.clearByPrefix('chautari_count_');
  }

  Future<void> _writeMyChautariCache(
    List<ChautariEntity> list,
    int page,
    int size,
  ) async {
    final payload = list
        .map(
          (item) => {
            'id': item.id,
            'name': item.name,
            'slug': item.slug,
            'description': item.description,
            'profileUrl': item.profileUrl,
            'creatorId': item.creatorId,
            'memberIds': item.memberIds,
            'createdAt': item.createdAt?.toIso8601String(),
          },
        )
        .toList(growable: false);
    await _cacheService.write(key: _myChautariKey(page, size), data: payload);
  }

  List<ChautariEntity>? _readMyChautariCache(int page, int size) {
    return _cacheService.read<List<ChautariEntity>>(
      key: _myChautariKey(page, size),
      maxAge: _myChautariTtl,
      decoder: (raw) {
        final list = (raw as List).cast<dynamic>();
        return list
            .map((item) {
              final map = (item as Map).cast<String, dynamic>();
              return ChautariEntity(
                id: map['id']?.toString() ?? '',
                name: map['name']?.toString() ?? '',
                slug: map['slug']?.toString() ?? '',
                description: map['description']?.toString() ?? '',
                profileUrl: map['profileUrl']?.toString(),
                creatorId: map['creatorId']?.toString() ?? '',
                memberIds: (map['memberIds'] as List<dynamic>? ?? const [])
                    .map((id) => id.toString())
                    .toList(growable: false),
                createdAt: DateTime.tryParse(
                  map['createdAt']?.toString() ?? '',
                ),
              );
            })
            .toList(growable: false);
      },
    );
  }

  Future<void> _writeCountCache(String userId, int value) async {
    await _cacheService.write(key: _countKey(userId), data: {'count': value});
  }

  int? _readCountCache(String userId, {Duration? maxAge}) {
    return _cacheService.read<int>(
      key: _countKey(userId),
      maxAge: maxAge,
      decoder: (raw) {
        final map = (raw as Map).cast<String, dynamic>();
        final countRaw = map['count'];
        if (countRaw is int) return countRaw;
        return int.tryParse(countRaw?.toString() ?? '0') ?? 0;
      },
    );
  }

  @override
  Future<Either<Failure, ChautariEntity>> createChautari({
    required String name,
    String? description,
    File? profileImage,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final item = await _remoteDatasource.createChautari(
        name: name,
        description: description,
        profileImage: profileImage,
      );
      await _clearMembershipCaches();
      return Right(item.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to create Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChautariEntity>> updateChautari({
    required String communityId,
    String? name,
    String? description,
    File? profileImage,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final item = await _remoteDatasource.updateChautari(
        communityId: communityId,
        name: name,
        description: description,
        profileImage: profileImage,
      );
      await _clearMembershipCaches();
      return Right(item.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChautariEntity>>> searchChautaris({
    required String search,
    int page = 1,
    int size = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final list = await _remoteDatasource.searchChautaris(
        search: search,
        page: page,
        size: size,
      );
      return Right(list.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to search Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChautariEntity>>> getMyChautaris({
    int page = 1,
    int size = 20,
  }) async {
    final cached = _readMyChautariCache(page, size);
    if (cached != null && cached.isNotEmpty) {
      return Right(cached);
    }

    if (!await _networkInfo.isConnected) {
      if (cached != null) return Right(cached);
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final list = await _remoteDatasource.getMyChautaris(
        page: page,
        size: size,
      );
      final entities = list.map((e) => e.toEntity()).toList();
      await _writeMyChautariCache(entities, page, size);
      return Right(entities);
    } on DioException catch (e) {
      if (cached != null) return Right(cached);
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to load my Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      if (cached != null) return Right(cached);
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChautariEntity>> getById(String communityId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final item = await _remoteDatasource.getById(communityId);
      return Right(item.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to get Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChautariEntity>> join(String communityId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final item = await _remoteDatasource.join(communityId);
      await _clearMembershipCaches();
      return Right(item.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to join Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChautariEntity>> leave(String communityId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final item = await _remoteDatasource.leave(communityId);
      await _clearMembershipCaches();
      return Right(item.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to leave Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getMemberCount(String communityId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      return Right(await _remoteDatasource.getMemberCount(communityId));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to get Chautari members',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUserChautariCount(String userId) async {
    if (!await _networkInfo.isConnected) {
      final cachedAnyAge = _readCountCache(userId);
      if (cachedAnyAge != null) return Right(cachedAnyAge);
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final total = await _remoteDatasource.getUserChautariCount(userId);
      await _writeCountCache(userId, total);
      return Right(total);
    } on DioException catch (e) {
      final cachedAnyAge = _readCountCache(userId);
      if (cachedAnyAge != null) return Right(cachedAnyAge);
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ??
              'Failed to get user Chautari count',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      final cachedAnyAge = _readCountCache(userId);
      if (cachedAnyAge != null) return Right(cachedAnyAge);
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createPost({
    required String communityId,
    String? caption,
    File? media,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      await _remoteDatasource.createPost(
        communityId: communityId,
        caption: caption,
        media: media,
      );
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to create Chautari post',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChautariPostsEntity>> getPosts({
    required String communityId,
    int page = 1,
    int size = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final posts = await _remoteDatasource.getPosts(
        communityId: communityId,
        page: page,
        size: size,
      );
      return Right(
        ChautariPostsEntity(
          posts: posts.map((item) => item.toEntity()).toList(),
          page: page,
          size: size,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to get Chautari posts',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteChautari(String communityId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      await _remoteDatasource.deleteChautari(communityId);
      await _clearMembershipCaches();
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to delete Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
