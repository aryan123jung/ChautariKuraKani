import 'package:equatable/equatable.dart';

enum CallTypeEntity { audio, video }

enum CallStatusEntity { ringing, accepted, rejected, missed, ended }

class CallUserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileUrl;

  const CallUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profileUrl,
  });

  String get fullName {
    final value = [
      firstName,
      lastName,
    ].where((item) => item.trim().isNotEmpty).join(' ').trim();
    if (value.isNotEmpty) return value;
    if (username.trim().isNotEmpty) return username;
    return 'User';
  }

  @override
  List<Object?> get props => [id, firstName, lastName, username, profileUrl];
}

class CallLogEntity extends Equatable {
  final String id;
  final CallUserEntity? caller;
  final CallUserEntity? callee;
  final String callerId;
  final String calleeId;
  final CallStatusEntity status;
  final CallTypeEntity callType;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final DateTime? createdAt;

  const CallLogEntity({
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

  @override
  List<Object?> get props => [
    id,
    caller,
    callee,
    callerId,
    calleeId,
    status,
    callType,
    startedAt,
    endedAt,
    durationSeconds,
    createdAt,
  ];
}

class ActiveCallEntity extends Equatable {
  final String callId;
  final String callerId;
  final String calleeId;
  final CallTypeEntity callType;
  final CallStatusEntity status;
  final bool isIncoming;

  const ActiveCallEntity({
    required this.callId,
    required this.callerId,
    required this.calleeId,
    required this.callType,
    required this.status,
    required this.isIncoming,
  });

  ActiveCallEntity copyWith({
    String? callId,
    String? callerId,
    String? calleeId,
    CallTypeEntity? callType,
    CallStatusEntity? status,
    bool? isIncoming,
  }) {
    return ActiveCallEntity(
      callId: callId ?? this.callId,
      callerId: callerId ?? this.callerId,
      calleeId: calleeId ?? this.calleeId,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      isIncoming: isIncoming ?? this.isIncoming,
    );
  }

  @override
  List<Object?> get props => [
    callId,
    callerId,
    calleeId,
    callType,
    status,
    isIncoming,
  ];
}
