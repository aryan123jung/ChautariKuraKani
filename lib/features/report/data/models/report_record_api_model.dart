import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';

class ReportRecordApiModel {
  final String id;
  final String targetId;
  final ReportTargetType targetType;
  final ReportReasonType reasonType;
  final ReportPriority priority;
  final ReportStatus status;
  final String reasonText;
  final List<String> evidenceUrls;
  final String? reporterUserId;
  final String? assignedTo;
  final AdminActionTaken actionTaken;
  final String? resolutionNote;
  final int? suspensionDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? targetData;

  const ReportRecordApiModel({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.reasonType,
    required this.priority,
    required this.status,
    required this.reasonText,
    required this.evidenceUrls,
    this.reporterUserId,
    this.assignedTo,
    this.actionTaken = AdminActionTaken.none,
    this.resolutionNote,
    this.suspensionDays,
    this.createdAt,
    this.updatedAt,
    this.targetData,
  });

  factory ReportRecordApiModel.fromJson(Map<String, dynamic> json) {
    final rawTargetId =
        json['targetId'] ??
        json['targetRefId'] ??
        json['targetUserId'] ??
        json['targetPostId'] ??
        json['targetCommunityId'] ??
        '';

    final rawReporter = json['reporterId'];
    final rawAssigned = json['assignedTo'];

    final evidenceRaw = json['evidenceUrls'];
    final evidence = evidenceRaw is List
        ? evidenceRaw.map((e) => e.toString()).toList()
        : <String>[];

    return ReportRecordApiModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      targetId: rawTargetId.toString(),
      targetType: ReportTargetTypeX.fromValue(
        json['targetType']?.toString() ?? json['entityType']?.toString(),
      ),
      reasonType: ReportReasonTypeX.fromValue(json['reasonType']?.toString()),
      priority: ReportPriorityX.fromValue(json['priority']?.toString()),
      status: ReportStatusX.fromValue(json['status']?.toString()),
      reasonText: (json['reasonText'] ?? '').toString(),
      evidenceUrls: evidence,
      reporterUserId: _extractId(rawReporter),
      assignedTo: _extractId(rawAssigned),
      actionTaken: AdminActionTakenX.fromValue(json['actionTaken']?.toString()),
      resolutionNote: json['resolutionNote']?.toString(),
      suspensionDays: _toIntOrNull(json['suspensionDays']),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
      targetData: _toMapOrNull(json['targetData']),
    );
  }

  ReportRecordEntity toEntity() {
    return ReportRecordEntity(
      id: id,
      targetId: targetId,
      targetType: targetType,
      reasonType: reasonType,
      priority: priority,
      status: status,
      reasonText: reasonText,
      evidenceUrls: evidenceUrls,
      reporterUserId: reporterUserId,
      assignedTo: assignedTo,
      actionTaken: actionTaken,
      resolutionNote: resolutionNote,
      suspensionDays: suspensionDays,
      createdAt: createdAt,
      updatedAt: updatedAt,
      targetData: targetData,
    );
  }

  static String? _extractId(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is Map<String, dynamic>) {
      return (raw['_id'] ?? raw['id'])?.toString();
    }
    return raw.toString();
  }

  static int? _toIntOrNull(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  static Map<String, dynamic>? _toMapOrNull(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    return null;
  }
}

class PagedReportRecordsApiModel {
  final List<ReportRecordApiModel> reports;
  final ReportPaginationEntity pagination;

  const PagedReportRecordsApiModel({
    required this.reports,
    required this.pagination,
  });

  factory PagedReportRecordsApiModel.fromResponse(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawList = rawData is List ? rawData : <dynamic>[];
    final rawPagination = json['pagination'];
    final paginationMap = rawPagination is Map<String, dynamic>
        ? rawPagination
        : <String, dynamic>{};

    final page = _toInt(paginationMap['page'], 1);
    final size = _toInt(paginationMap['size'], 10);
    final total = _toInt(paginationMap['totalReports'], -1) >= 0
        ? _toInt(paginationMap['totalReports'], 0)
        : _toInt(paginationMap['total'], 0);

    return PagedReportRecordsApiModel(
      reports: rawList
          .whereType<Map<String, dynamic>>()
          .map(ReportRecordApiModel.fromJson)
          .toList(),
      pagination: ReportPaginationEntity(
        page: page,
        size: size,
        total: total,
        totalPages: _toInt(paginationMap['totalPages'], 1),
      ),
    );
  }

  PagedReportRecordsEntity toEntity() {
    return PagedReportRecordsEntity(
      reports: reports.map((r) => r.toEntity()).toList(),
      pagination: pagination,
    );
  }

  static int _toInt(dynamic raw, int fallback) {
    if (raw is int) return raw;
    final parsed = int.tryParse(raw?.toString() ?? '');
    return parsed ?? fallback;
  }
}

class AdminReportStatsApiModel {
  final int total;
  final int pending;
  final int inReview;
  final int resolved;
  final int rejected;
  final int escalated;

  const AdminReportStatsApiModel({
    required this.total,
    required this.pending,
    required this.inReview,
    required this.resolved,
    required this.rejected,
    required this.escalated,
  });

  factory AdminReportStatsApiModel.fromResponse(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : <String, dynamic>{};

    int readAny(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value is int) return value;
        final parsed = int.tryParse(value?.toString() ?? '');
        if (parsed != null) return parsed;
      }
      return 0;
    }

    return AdminReportStatsApiModel(
      total: readAny(const ['total', 'totalReports']),
      pending: readAny(const ['pending']),
      inReview: readAny(const ['inReview', 'in_review']),
      resolved: readAny(const ['resolved']),
      rejected: readAny(const ['rejected']),
      escalated: readAny(const ['escalated']),
    );
  }

  AdminReportStatsEntity toEntity() {
    return AdminReportStatsEntity(
      total: total,
      pending: pending,
      inReview: inReview,
      resolved: resolved,
      rejected: rejected,
      escalated: escalated,
    );
  }
}
