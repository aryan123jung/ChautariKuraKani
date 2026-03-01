import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/services/connectivity/network_info.dart';
import 'package:chautari_kurakani/features/report/data/datasources/report_datasource.dart';
import 'package:chautari_kurakani/features/report/data/datasources/remote/report_remote_datasource.dart';
import 'package:chautari_kurakani/features/report/data/models/create_report_api_model.dart';
import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';
import 'package:chautari_kurakani/features/report/domain/repositories/report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportRepositoryProvider = Provider<IReportRepository>((ref) {
  return ReportRepository(
    remoteDatasource: ref.read(reportRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ReportRepository implements IReportRepository {
  final NetworkInfo _networkInfo;
  final IReportRemoteDatasource _remoteDatasource;

  ReportRepository({
    required IReportRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  Future<Either<Failure, T>> _guard<T>(
    Future<T> Function() run,
    String fallbackMessage,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final value = await run();
      return Right(value);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String? message;
      if (responseData is Map<String, dynamic>) {
        message = responseData['message']?.toString();
      }
      return Left(
        ApiFailure(
          message: message ?? fallbackMessage,
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> reportPost(
    String postId,
    CreateReportParams params,
  ) async {
    final result = await _guard(
      () => _remoteDatasource.reportPost(
        postId,
        CreateReportApiModel.fromParams(params),
      ),
      'Failed to report post',
    );

    return result.fold((l) => Left(l), (_) => const Right(true));
  }

  @override
  Future<Either<Failure, bool>> reportUser(
    String userId,
    CreateReportParams params,
  ) async {
    final result = await _guard(
      () => _remoteDatasource.reportUser(
        userId,
        CreateReportApiModel.fromParams(params),
      ),
      'Failed to report user',
    );

    return result.fold((l) => Left(l), (_) => const Right(true));
  }

  @override
  Future<Either<Failure, bool>> reportChautari(
    String communityId,
    CreateReportParams params,
  ) async {
    final result = await _guard(
      () => _remoteDatasource.reportChautari(
        communityId,
        CreateReportApiModel.fromParams(params),
      ),
      'Failed to report Chautari',
    );

    return result.fold((l) => Left(l), (_) => const Right(true));
  }

  @override
  Future<Either<Failure, PagedReportRecordsEntity>> getMyReports({
    int page = 1,
    int size = 10,
  }) async {
    final result = await _guard(
      () => _remoteDatasource.getMyReports(page: page, size: size),
      'Failed to fetch my reports',
    );

    return result.fold((l) => Left(l), (r) => Right(r.toEntity()));
  }

  @override
  Future<Either<Failure, AdminReportStatsEntity>> getAdminReportStats() async {
    final result = await _guard(
      () => _remoteDatasource.getAdminReportStats(),
      'Failed to fetch report stats',
    );

    return result.fold((l) => Left(l), (r) => Right(r.toEntity()));
  }

  @override
  Future<Either<Failure, PagedReportRecordsEntity>> getAdminReports(
    AdminReportListQuery query,
  ) async {
    final result = await _guard(
      () => _remoteDatasource.getAdminReports(query),
      'Failed to fetch admin reports',
    );

    return result.fold((l) => Left(l), (r) => Right(r.toEntity()));
  }

  @override
  Future<Either<Failure, ReportRecordEntity>> getAdminReportById(
    String reportId,
  ) async {
    final result = await _guard(
      () => _remoteDatasource.getAdminReportById(reportId),
      'Failed to fetch report details',
    );

    return result.fold((l) => Left(l), (r) => Right(r.toEntity()));
  }

  @override
  Future<Either<Failure, bool>> assignAdminReport(
    String reportId,
    String assignedTo,
  ) async {
    final result = await _guard(
      () => _remoteDatasource.assignAdminReport(reportId, assignedTo),
      'Failed to assign report',
    );

    return result.fold((l) => Left(l), (_) => const Right(true));
  }

  @override
  Future<Either<Failure, bool>> resolveAdminReport(
    String reportId,
    ResolveReportParams params,
  ) async {
    final result = await _guard(
      () => _remoteDatasource.resolveAdminReport(reportId, params),
      'Failed to resolve report',
    );

    return result.fold((l) => Left(l), (_) => const Right(true));
  }
}
