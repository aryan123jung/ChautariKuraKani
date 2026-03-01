import 'package:chautari_kurakani/core/api/api_client.dart';
import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/report/data/datasources/report_datasource.dart';
import 'package:chautari_kurakani/features/report/data/models/create_report_api_model.dart';
import 'package:chautari_kurakani/features/report/data/models/report_record_api_model.dart';
import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportRemoteDatasourceProvider = Provider<IReportRemoteDatasource>((ref) {
  return ReportRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ReportRemoteDatasource implements IReportRemoteDatasource {
  final ApiClient _apiClient;

  ReportRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<void> reportPost(String postId, CreateReportApiModel payload) async {
    await _apiClient.post(
      ApiEndpoints.reportPost(postId),
      data: payload.toJson(),
    );
  }

  @override
  Future<void> reportUser(String userId, CreateReportApiModel payload) async {
    await _apiClient.post(
      ApiEndpoints.reportUser(userId),
      data: payload.toJson(),
    );
  }

  @override
  Future<void> reportChautari(
    String communityId,
    CreateReportApiModel payload,
  ) async {
    await _apiClient.post(
      ApiEndpoints.reportChautari(communityId),
      data: payload.toJson(),
    );
  }

  @override
  Future<PagedReportRecordsApiModel> getMyReports({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.myReports,
      queryParameters: {'page': page, 'size': size},
    );
    return PagedReportRecordsApiModel.fromResponse(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<AdminReportStatsApiModel> getAdminReportStats() async {
    final response = await _apiClient.get(ApiEndpoints.adminReportsStats);
    return AdminReportStatsApiModel.fromResponse(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PagedReportRecordsApiModel> getAdminReports(
    AdminReportListQuery query,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminReports,
      queryParameters: query.toQueryParameters(),
    );
    return PagedReportRecordsApiModel.fromResponse(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ReportRecordApiModel> getAdminReportById(String reportId) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminReportById(reportId),
    );
    final data = response.data as Map<String, dynamic>;
    return ReportRecordApiModel.fromJson(
      (data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    );
  }

  @override
  Future<void> assignAdminReport(String reportId, String assignedTo) async {
    await _apiClient.patch(
      ApiEndpoints.adminAssignReport(reportId),
      data: {'assignedTo': assignedTo},
    );
  }

  @override
  Future<void> resolveAdminReport(
    String reportId,
    ResolveReportParams params,
  ) async {
    await _apiClient.patch(
      ApiEndpoints.adminResolveReport(reportId),
      data: params.toJson(),
    );
  }
}
