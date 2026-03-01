import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/report/data/repositories/report_repository.dart';
import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';
import 'package:chautari_kurakani/features/report/domain/repositories/report_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportTargetParams extends Equatable {
  final String targetId;
  final CreateReportParams payload;

  const ReportTargetParams({required this.targetId, required this.payload});

  @override
  List<Object?> get props => [targetId, payload];
}

class MyReportsQueryParams extends Equatable {
  final int page;
  final int size;

  const MyReportsQueryParams({this.page = 1, this.size = 10});

  @override
  List<Object?> get props => [page, size];
}

class AssignAdminReportParams extends Equatable {
  final String reportId;
  final String assignedTo;

  const AssignAdminReportParams({
    required this.reportId,
    required this.assignedTo,
  });

  @override
  List<Object?> get props => [reportId, assignedTo];
}

class ResolveAdminReportParams extends Equatable {
  final String reportId;
  final ResolveReportParams payload;

  const ResolveAdminReportParams({
    required this.reportId,
    required this.payload,
  });

  @override
  List<Object?> get props => [reportId, payload];
}

final reportPostUsecaseProvider = Provider<ReportPostUsecase>((ref) {
  return ReportPostUsecase(repository: ref.read(reportRepositoryProvider));
});

final reportUserUsecaseProvider = Provider<ReportUserUsecase>((ref) {
  return ReportUserUsecase(repository: ref.read(reportRepositoryProvider));
});

final reportChautariUsecaseProvider = Provider<ReportChautariUsecase>((ref) {
  return ReportChautariUsecase(repository: ref.read(reportRepositoryProvider));
});

final getMyReportsUsecaseProvider = Provider<GetMyReportsUsecase>((ref) {
  return GetMyReportsUsecase(repository: ref.read(reportRepositoryProvider));
});

final getAdminReportStatsUsecaseProvider = Provider<GetAdminReportStatsUsecase>(
  (ref) {
    return GetAdminReportStatsUsecase(
      repository: ref.read(reportRepositoryProvider),
    );
  },
);

final getAdminReportsUsecaseProvider = Provider<GetAdminReportsUsecase>((ref) {
  return GetAdminReportsUsecase(repository: ref.read(reportRepositoryProvider));
});

final getAdminReportByIdUsecaseProvider = Provider<GetAdminReportByIdUsecase>((
  ref,
) {
  return GetAdminReportByIdUsecase(
    repository: ref.read(reportRepositoryProvider),
  );
});

final assignAdminReportUsecaseProvider = Provider<AssignAdminReportUsecase>((
  ref,
) {
  return AssignAdminReportUsecase(
    repository: ref.read(reportRepositoryProvider),
  );
});

final resolveAdminReportUsecaseProvider = Provider<ResolveAdminReportUsecase>((
  ref,
) {
  return ResolveAdminReportUsecase(
    repository: ref.read(reportRepositoryProvider),
  );
});

class ReportPostUsecase implements UsecaseWithParams<bool, ReportTargetParams> {
  final IReportRepository _repository;

  ReportPostUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ReportTargetParams params) {
    return _repository.reportPost(params.targetId, params.payload);
  }
}

class ReportUserUsecase implements UsecaseWithParams<bool, ReportTargetParams> {
  final IReportRepository _repository;

  ReportUserUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ReportTargetParams params) {
    return _repository.reportUser(params.targetId, params.payload);
  }
}

class ReportChautariUsecase
    implements UsecaseWithParams<bool, ReportTargetParams> {
  final IReportRepository _repository;

  ReportChautariUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ReportTargetParams params) {
    return _repository.reportChautari(params.targetId, params.payload);
  }
}

class GetMyReportsUsecase
    implements
        UsecaseWithParams<PagedReportRecordsEntity, MyReportsQueryParams> {
  final IReportRepository _repository;

  GetMyReportsUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PagedReportRecordsEntity>> call(
    MyReportsQueryParams params,
  ) {
    return _repository.getMyReports(page: params.page, size: params.size);
  }
}

class GetAdminReportStatsUsecase
    implements UsecaseWithoutParams<AdminReportStatsEntity> {
  final IReportRepository _repository;

  GetAdminReportStatsUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AdminReportStatsEntity>> call() {
    return _repository.getAdminReportStats();
  }
}

class GetAdminReportsUsecase
    implements
        UsecaseWithParams<PagedReportRecordsEntity, AdminReportListQuery> {
  final IReportRepository _repository;

  GetAdminReportsUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PagedReportRecordsEntity>> call(
    AdminReportListQuery params,
  ) {
    return _repository.getAdminReports(params);
  }
}

class GetAdminReportByIdUsecase
    implements UsecaseWithParams<ReportRecordEntity, String> {
  final IReportRepository _repository;

  GetAdminReportByIdUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ReportRecordEntity>> call(String params) {
    return _repository.getAdminReportById(params);
  }
}

class AssignAdminReportUsecase
    implements UsecaseWithParams<bool, AssignAdminReportParams> {
  final IReportRepository _repository;

  AssignAdminReportUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(AssignAdminReportParams params) {
    return _repository.assignAdminReport(params.reportId, params.assignedTo);
  }
}

class ResolveAdminReportUsecase
    implements UsecaseWithParams<bool, ResolveAdminReportParams> {
  final IReportRepository _repository;

  ResolveAdminReportUsecase({required IReportRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ResolveAdminReportParams params) {
    return _repository.resolveAdminReport(params.reportId, params.payload);
  }
}
