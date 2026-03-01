import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';
import 'package:chautari_kurakani/features/report/domain/usecases/report_usecases.dart';
import 'package:chautari_kurakani/features/report/presentation/state/report_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportViewModelProvider = NotifierProvider<ReportViewModel, ReportState>(
  ReportViewModel.new,
);

class ReportViewModel extends Notifier<ReportState> {
  late final ReportPostUsecase _reportPostUsecase;
  late final ReportUserUsecase _reportUserUsecase;
  late final ReportChautariUsecase _reportChautariUsecase;
  late final GetMyReportsUsecase _getMyReportsUsecase;
  late final GetAdminReportStatsUsecase _getAdminReportStatsUsecase;
  late final GetAdminReportsUsecase _getAdminReportsUsecase;
  late final GetAdminReportByIdUsecase _getAdminReportByIdUsecase;
  late final AssignAdminReportUsecase _assignAdminReportUsecase;
  late final ResolveAdminReportUsecase _resolveAdminReportUsecase;

  @override
  ReportState build() {
    _reportPostUsecase = ref.read(reportPostUsecaseProvider);
    _reportUserUsecase = ref.read(reportUserUsecaseProvider);
    _reportChautariUsecase = ref.read(reportChautariUsecaseProvider);
    _getMyReportsUsecase = ref.read(getMyReportsUsecaseProvider);
    _getAdminReportStatsUsecase = ref.read(getAdminReportStatsUsecaseProvider);
    _getAdminReportsUsecase = ref.read(getAdminReportsUsecaseProvider);
    _getAdminReportByIdUsecase = ref.read(getAdminReportByIdUsecaseProvider);
    _assignAdminReportUsecase = ref.read(assignAdminReportUsecaseProvider);
    _resolveAdminReportUsecase = ref.read(resolveAdminReportUsecaseProvider);
    return const ReportState.initial();
  }

  void _setSubmitting() {
    state = state.copyWith(
      status: ReportUiStatus.submitting,
      errorMessage: null,
    );
  }

  void _setError(String message) {
    state = state.copyWith(status: ReportUiStatus.error, errorMessage: message);
  }

  void _setSuccess() {
    state = state.copyWith(status: ReportUiStatus.success, errorMessage: null);
  }

  Future<bool> reportPost(String postId, CreateReportParams payload) async {
    _setSubmitting();
    final result = await _reportPostUsecase(
      ReportTargetParams(targetId: postId, payload: payload),
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) {
        _setSuccess();
        return true;
      },
    );
  }

  Future<bool> reportUser(String userId, CreateReportParams payload) async {
    _setSubmitting();
    final result = await _reportUserUsecase(
      ReportTargetParams(targetId: userId, payload: payload),
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) {
        _setSuccess();
        return true;
      },
    );
  }

  Future<bool> reportChautari(
    String communityId,
    CreateReportParams payload,
  ) async {
    _setSubmitting();
    final result = await _reportChautariUsecase(
      ReportTargetParams(targetId: communityId, payload: payload),
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) {
        _setSuccess();
        return true;
      },
    );
  }

  Future<PagedReportRecordsEntity?> getMyReports({
    int page = 1,
    int size = 10,
  }) async {
    _setSubmitting();
    final result = await _getMyReportsUsecase(
      MyReportsQueryParams(page: page, size: size),
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (data) {
        _setSuccess();
        return data;
      },
    );
  }

  Future<AdminReportStatsEntity?> getAdminReportStats() async {
    _setSubmitting();
    final result = await _getAdminReportStatsUsecase();

    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (data) {
        _setSuccess();
        return data;
      },
    );
  }

  Future<PagedReportRecordsEntity?> getAdminReports(
    AdminReportListQuery query,
  ) async {
    _setSubmitting();
    final result = await _getAdminReportsUsecase(query);

    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (data) {
        _setSuccess();
        return data;
      },
    );
  }

  Future<ReportRecordEntity?> getAdminReportById(String reportId) async {
    _setSubmitting();
    final result = await _getAdminReportByIdUsecase(reportId);

    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (data) {
        _setSuccess();
        return data;
      },
    );
  }

  Future<bool> assignAdminReport(String reportId, String assignedTo) async {
    _setSubmitting();
    final result = await _assignAdminReportUsecase(
      AssignAdminReportParams(reportId: reportId, assignedTo: assignedTo),
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) {
        _setSuccess();
        return true;
      },
    );
  }

  Future<bool> resolveAdminReport(
    String reportId,
    ResolveReportParams payload,
  ) async {
    _setSubmitting();
    final result = await _resolveAdminReportUsecase(
      ResolveAdminReportParams(reportId: reportId, payload: payload),
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) {
        _setSuccess();
        return true;
      },
    );
  }
}
