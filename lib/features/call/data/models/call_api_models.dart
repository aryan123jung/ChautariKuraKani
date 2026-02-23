import 'package:chautari_kurakani/core/api/api_endpoints.dart';
import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';

class CallUserApiModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileUrl;

  const CallUserApiModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profileUrl,
  });

  factory CallUserApiModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CallUserApiModel(
        id: json['_id']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        profileUrl: _resolveProfile(json['profileUrl']?.toString()),
      );
    }

    return CallUserApiModel(
      id: json?.toString() ?? '',
      firstName: '',
      lastName: '',
      username: '',
      profileUrl: null,
    );
  }

  CallUserEntity toEntity() {
    return CallUserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      profileUrl: profileUrl,
    );
  }

  static String? _resolveProfile(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    if (value.startsWith('http')) return value;
    if (value.contains('/') || value.contains('\\')) {
      return ApiEndpoints.uploadUrl(value);
    }
    return ApiEndpoints.profileImageUrl(value);
  }
}

class CallLogApiModel {
  final String id;
  final String callerId;
  final String calleeId;
  final CallUserApiModel? caller;
  final CallUserApiModel? callee;
  final CallStatusEntity status;
  final CallTypeEntity callType;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final DateTime? createdAt;

  const CallLogApiModel({
    required this.id,
    required this.callerId,
    required this.calleeId,
    required this.status,
    required this.callType,
    this.caller,
    this.callee,
    this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.createdAt,
  });

  factory CallLogApiModel.fromJson(Map<String, dynamic> json) {
    final callerRaw = json['callerId'];
    final calleeRaw = json['calleeId'];

    final callerId = callerRaw is Map<String, dynamic>
        ? callerRaw['_id']?.toString() ?? ''
        : callerRaw?.toString() ?? '';
    final calleeId = calleeRaw is Map<String, dynamic>
        ? calleeRaw['_id']?.toString() ?? ''
        : calleeRaw?.toString() ?? '';

    return CallLogApiModel(
      id: json['_id']?.toString() ?? '',
      callerId: callerId,
      calleeId: calleeId,
      caller: callerRaw is Map<String, dynamic>
          ? CallUserApiModel.fromJson(callerRaw)
          : null,
      callee: calleeRaw is Map<String, dynamic>
          ? CallUserApiModel.fromJson(calleeRaw)
          : null,
      status: _parseStatus(json['status']?.toString()),
      callType: _parseType(json['callType']?.toString()),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      endedAt: DateTime.tryParse(json['endedAt']?.toString() ?? ''),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  CallLogEntity toEntity() {
    return CallLogEntity(
      id: id,
      callerId: callerId,
      calleeId: calleeId,
      status: status,
      callType: callType,
      caller: caller?.toEntity(),
      callee: callee?.toEntity(),
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      createdAt: createdAt,
    );
  }

  static CallTypeEntity _parseType(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'video':
        return CallTypeEntity.video;
      default:
        return CallTypeEntity.audio;
    }
  }

  static CallStatusEntity _parseStatus(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'ACCEPTED':
        return CallStatusEntity.accepted;
      case 'REJECTED':
        return CallStatusEntity.rejected;
      case 'MISSED':
        return CallStatusEntity.missed;
      case 'ENDED':
        return CallStatusEntity.ended;
      default:
        return CallStatusEntity.ringing;
    }
  }
}
