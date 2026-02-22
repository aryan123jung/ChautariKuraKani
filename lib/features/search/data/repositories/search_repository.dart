import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
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
  );
});

class SearchRepository implements ISearchRepository {
  final ISearchRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  SearchRepository({
    required ISearchRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<SearchUserEntity>>> searchUsers({
    required String query,
    int page = 1,
    int size = 10,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final users = await _remoteDatasource.searchUsers(
        query: query,
        page: page,
        size: size,
      );
      return Right(users.map((user) => user.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to search users',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
