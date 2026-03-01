import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/core/services/hive/app_cache_service.dart';
import 'package:chautari_kurakani/features/search/data/datasources/remote/search_remote_datasource.dart';
import 'package:chautari_kurakani/features/search/data/datasources/search_datasource.dart';
import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:chautari_kurakani/features/search/domain/repositories/search_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRepositoryProvider = Provider<ISearchRepository>((ref) {
  return SearchRepository(
    remoteDatasource: ref.read(searchRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    cacheService: ref.read(appCacheServiceProvider),
  );
});

class SearchRepository implements ISearchRepository {
  final ISearchRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;
  final AppCacheService _cacheService;

  SearchRepository({
    required ISearchRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
    required AppCacheService cacheService,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo,
       _cacheService = cacheService;

  static const _searchTtl = Duration(minutes: 3);

  String _searchKey({
    required String query,
    required int page,
    required int size,
  }) {
    return 'search_users_${query.trim().toLowerCase()}_${page}_$size';
  }

  List<SearchUserEntity>? _readCachedUsers({
    required String query,
    required int page,
    required int size,
    Duration? maxAge,
  }) {
    return _cacheService.read<List<SearchUserEntity>>(
      key: _searchKey(query: query, page: page, size: size),
      maxAge: maxAge,
      decoder: (raw) {
        final list = (raw as List).cast<dynamic>();
        return list
            .map((item) {
              final map = (item as Map).cast<String, dynamic>();
              return SearchUserEntity(
                id: map['id']?.toString() ?? '',
                firstName: map['firstName']?.toString() ?? '',
                lastName: map['lastName']?.toString() ?? '',
                username: map['username']?.toString() ?? '',
                email: map['email']?.toString() ?? '',
                profileUrl: map['profileUrl']?.toString(),
                coverUrl: map['coverUrl']?.toString(),
              );
            })
            .toList(growable: false);
      },
    );
  }

  Future<void> _writeCachedUsers({
    required String query,
    required int page,
    required int size,
    required List<SearchUserEntity> users,
  }) async {
    await _cacheService.write(
      key: _searchKey(query: query, page: page, size: size),
      data: users
          .map(
            (user) => {
              'id': user.id,
              'firstName': user.firstName,
              'lastName': user.lastName,
              'username': user.username,
              'email': user.email,
              'profileUrl': user.profileUrl,
              'coverUrl': user.coverUrl,
            },
          )
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, List<SearchUserEntity>>> searchUsers({
    required String query,
    int page = 1,
    int size = 10,
  }) async {
    final cached = _readCachedUsers(
      query: query,
      page: page,
      size: size,
      maxAge: _searchTtl,
    );
    if (cached != null && cached.isNotEmpty) {
      return Right(cached);
    }

    if (!await _networkInfo.isConnected) {
      if (cached != null) return Right(cached);
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final users = await _remoteDatasource.searchUsers(
        query: query,
        page: page,
        size: size,
      );
      final entities = users.map((user) => user.toEntity()).toList();
      await _writeCachedUsers(
        query: query,
        page: page,
        size: size,
        users: entities,
      );
      return Right(entities);
    } on DioException catch (e) {
      if (cached != null) return Right(cached);
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to search users',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      if (cached != null) return Right(cached);
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
