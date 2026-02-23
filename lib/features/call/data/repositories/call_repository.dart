import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
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
  );
});

class CallRepository implements ICallRepository {
  final ICallRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  CallRepository({
    required ICallRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<CallLogEntity>>> listMyCalls({
    int page = 1,
    int size = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final calls = await _remoteDatasource.listMyCalls(page: page, size: size);
      return Right(calls.map((item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ?? 'Failed to fetch call history',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
