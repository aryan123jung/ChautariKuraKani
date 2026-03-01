import 'package:equatable/equatable.dart';

enum ReportReasonType {
  spam,
  harassment,
  hate,
  violence,
  nudity,
  scam,
  misinformation,
  impersonation,
  other,
}

enum ReportPriority { low, medium, high, critical }

enum ReportTargetType { user, post, community, unknown }

enum ReportStatus { pending, inReview, resolved, rejected, escalated, unknown }

enum AdminActionTaken { none, ban, suspend, delete, unknown }

extension ReportReasonTypeX on ReportReasonType {
  String get value {
    switch (this) {
      case ReportReasonType.spam:
        return 'spam';
      case ReportReasonType.harassment:
        return 'harassment';
      case ReportReasonType.hate:
        return 'hate';
      case ReportReasonType.violence:
        return 'violence';
      case ReportReasonType.nudity:
        return 'nudity';
      case ReportReasonType.scam:
        return 'scam';
      case ReportReasonType.misinformation:
        return 'misinformation';
      case ReportReasonType.impersonation:
        return 'impersonation';
      case ReportReasonType.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case ReportReasonType.spam:
        return 'Spam';
      case ReportReasonType.harassment:
        return 'Harassment';
      case ReportReasonType.hate:
        return 'Hate';
      case ReportReasonType.violence:
        return 'Violence';
      case ReportReasonType.nudity:
        return 'Nudity';
      case ReportReasonType.scam:
        return 'Scam';
      case ReportReasonType.misinformation:
        return 'Misinformation';
      case ReportReasonType.impersonation:
        return 'Impersonation';
      case ReportReasonType.other:
        return 'Other';
    }
  }

  static ReportReasonType fromValue(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'spam':
        return ReportReasonType.spam;
      case 'harassment':
        return ReportReasonType.harassment;
      case 'hate':
        return ReportReasonType.hate;
      case 'violence':
        return ReportReasonType.violence;
      case 'nudity':
        return ReportReasonType.nudity;
      case 'scam':
        return ReportReasonType.scam;
      case 'misinformation':
        return ReportReasonType.misinformation;
      case 'impersonation':
        return ReportReasonType.impersonation;
      default:
        return ReportReasonType.other;
    }
  }
}

extension ReportPriorityX on ReportPriority {
  String get value {
    switch (this) {
      case ReportPriority.low:
        return 'low';
      case ReportPriority.medium:
        return 'medium';
      case ReportPriority.high:
        return 'high';
      case ReportPriority.critical:
        return 'critical';
    }
  }

  String get label {
    switch (this) {
      case ReportPriority.low:
        return 'Low';
      case ReportPriority.medium:
        return 'Medium';
      case ReportPriority.high:
        return 'High';
      case ReportPriority.critical:
        return 'Critical';
    }
  }

  static ReportPriority fromValue(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'low':
        return ReportPriority.low;
      case 'high':
        return ReportPriority.high;
      case 'critical':
        return ReportPriority.critical;
      default:
        return ReportPriority.medium;
    }
  }
}

extension ReportTargetTypeX on ReportTargetType {
  String get value {
    switch (this) {
      case ReportTargetType.user:
        return 'user';
      case ReportTargetType.post:
        return 'post';
      case ReportTargetType.community:
        return 'community';
      case ReportTargetType.unknown:
        return 'unknown';
    }
  }

  static ReportTargetType fromValue(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'user':
        return ReportTargetType.user;
      case 'post':
        return ReportTargetType.post;
      case 'community':
      case 'chautari':
        return ReportTargetType.community;
      default:
        return ReportTargetType.unknown;
    }
  }
}

extension ReportStatusX on ReportStatus {
  String get value {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.inReview:
        return 'in_review';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
      case ReportStatus.escalated:
        return 'escalated';
      case ReportStatus.unknown:
        return 'unknown';
    }
  }

  static ReportStatus fromValue(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'in_review':
        return ReportStatus.inReview;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      case 'escalated':
        return ReportStatus.escalated;
      default:
        return ReportStatus.unknown;
    }
  }
}

extension AdminActionTakenX on AdminActionTaken {
  String get value {
    switch (this) {
      case AdminActionTaken.none:
        return 'none';
      case AdminActionTaken.ban:
        return 'ban';
      case AdminActionTaken.suspend:
        return 'suspend';
      case AdminActionTaken.delete:
        return 'delete';
      case AdminActionTaken.unknown:
        return 'unknown';
    }
  }

  static AdminActionTaken fromValue(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'none':
        return AdminActionTaken.none;
      case 'ban':
        return AdminActionTaken.ban;
      case 'suspend':
        return AdminActionTaken.suspend;
      case 'delete':
        return AdminActionTaken.delete;
      default:
        return AdminActionTaken.unknown;
    }
  }
}

class CreateReportParams extends Equatable {
  final ReportReasonType reasonType;
  final ReportPriority priority;
  final String reasonText;
  final List<String> evidenceUrls;

  const CreateReportParams({
    required this.reasonType,
    this.priority = ReportPriority.medium,
    this.reasonText = '',
    this.evidenceUrls = const [],
  });

  Map<String, dynamic> toJson() {
    final cleanedEvidence = evidenceUrls
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return {
      'reasonType': reasonType.value,
      'priority': priority.value,
      'reasonText': reasonText.trim(),
      'evidenceUrls': cleanedEvidence,
    };
  }

  @override
  List<Object?> get props => [reasonType, priority, reasonText, evidenceUrls];
}

class ReportRecordEntity extends Equatable {
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

  const ReportRecordEntity({
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

  @override
  List<Object?> get props => [
    id,
    targetId,
    targetType,
    reasonType,
    priority,
    status,
    reasonText,
    evidenceUrls,
    reporterUserId,
    assignedTo,
    actionTaken,
    resolutionNote,
    suspensionDays,
    createdAt,
    updatedAt,
    targetData,
  ];
}

class ReportPaginationEntity extends Equatable {
  final int page;
  final int size;
  final int total;
  final int totalPages;

  const ReportPaginationEntity({
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [page, size, total, totalPages];
}

class PagedReportRecordsEntity extends Equatable {
  final List<ReportRecordEntity> reports;
  final ReportPaginationEntity pagination;

  const PagedReportRecordsEntity({
    required this.reports,
    required this.pagination,
  });

  @override
  List<Object?> get props => [reports, pagination];
}

class AdminReportStatsEntity extends Equatable {
  final int total;
  final int pending;
  final int inReview;
  final int resolved;
  final int rejected;
  final int escalated;

  const AdminReportStatsEntity({
    required this.total,
    required this.pending,
    required this.inReview,
    required this.resolved,
    required this.rejected,
    required this.escalated,
  });

  const AdminReportStatsEntity.empty()
    : total = 0,
      pending = 0,
      inReview = 0,
      resolved = 0,
      rejected = 0,
      escalated = 0;

  @override
  List<Object?> get props => [
    total,
    pending,
    inReview,
    resolved,
    rejected,
    escalated,
  ];
}

class AdminReportListQuery extends Equatable {
  final int page;
  final int size;
  final ReportStatus? status;
  final ReportTargetType? targetType;
  final ReportReasonType? reasonType;
  final ReportPriority? priority;
  final String? assignedTo;

  const AdminReportListQuery({
    this.page = 1,
    this.size = 10,
    this.status,
    this.targetType,
    this.reasonType,
    this.priority,
    this.assignedTo,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'size': size,
      if (status != null) 'status': status!.value,
      if (targetType != null && targetType != ReportTargetType.unknown)
        'targetType': targetType!.value,
      if (reasonType != null) 'reasonType': reasonType!.value,
      if (priority != null) 'priority': priority!.value,
      if (assignedTo != null && assignedTo!.trim().isNotEmpty)
        'assignedTo': assignedTo!.trim(),
    };
  }

  @override
  List<Object?> get props => [
    page,
    size,
    status,
    targetType,
    reasonType,
    priority,
    assignedTo,
  ];
}

class ResolveReportParams extends Equatable {
  final ReportStatus status;
  final AdminActionTaken actionTaken;
  final String resolutionNote;
  final int? suspensionDays;

  const ResolveReportParams({
    required this.status,
    required this.actionTaken,
    this.resolutionNote = '',
    this.suspensionDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
      'actionTaken': actionTaken.value,
      if (resolutionNote.trim().isNotEmpty)
        'resolutionNote': resolutionNote.trim(),
      if (suspensionDays != null) 'suspensionDays': suspensionDays,
    };
  }

  @override
  List<Object?> get props => [
    status,
    actionTaken,
    resolutionNote,
    suspensionDays,
  ];
}
