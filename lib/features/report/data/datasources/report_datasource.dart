import 'package:chautari_kurakani/features/report/data/models/create_report_api_model.dart';
import 'package:chautari_kurakani/features/report/data/models/report_record_api_model.dart';
import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';

abstract class IReportRemoteDatasource {
  Future<void> reportPost(String postId, CreateReportApiModel payload);
  Future<void> reportUser(String userId, CreateReportApiModel payload);
  Future<void> reportChautari(String communityId, CreateReportApiModel payload);

  Future<PagedReportRecordsApiModel> getMyReports({
    int page = 1,
    int size = 10,
  });

  Future<AdminReportStatsApiModel> getAdminReportStats();

  Future<PagedReportRecordsApiModel> getAdminReports(
    AdminReportListQuery query,
  );

  Future<ReportRecordApiModel> getAdminReportById(String reportId);

  Future<void> assignAdminReport(String reportId, String assignedTo);

  Future<void> resolveAdminReport(String reportId, ResolveReportParams params);
}
