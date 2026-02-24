import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
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
  );
});

class ChautariRepository implements IChautariRepository {
  final IChautariRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  ChautariRepository({
    required IChautariRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

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
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final list = await _remoteDatasource.getMyChautaris(
        page: page,
        size: size,
      );
      return Right(list.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to load my Chautari',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
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
