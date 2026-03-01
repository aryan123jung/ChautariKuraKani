import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IReportRepository {
  Future<Either<Failure, bool>> reportPost(
    String postId,
    CreateReportParams params,
  );

  Future<Either<Failure, bool>> reportUser(
    String userId,
    CreateReportParams params,
  );

  Future<Either<Failure, bool>> reportChautari(
    String communityId,
    CreateReportParams params,
  );

  Future<Either<Failure, PagedReportRecordsEntity>> getMyReports({
    int page = 1,
    int size = 10,
  });

  Future<Either<Failure, AdminReportStatsEntity>> getAdminReportStats();

  Future<Either<Failure, PagedReportRecordsEntity>> getAdminReports(
    AdminReportListQuery query,
  );

  Future<Either<Failure, ReportRecordEntity>> getAdminReportById(
    String reportId,
  );

  Future<Either<Failure, bool>> assignAdminReport(
    String reportId,
    String assignedTo,
  );

  Future<Either<Failure, bool>> resolveAdminReport(
    String reportId,
    ResolveReportParams params,
  );
}
