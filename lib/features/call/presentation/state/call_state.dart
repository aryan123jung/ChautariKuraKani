import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:equatable/equatable.dart';

enum CallUiStatus { initial, loading, loaded, submitting, error }

class CallState extends Equatable {
  final CallUiStatus status;
  final List<CallLogEntity> callHistory;
  final ActiveCallEntity? activeCall;
  final ActiveCallEntity? incomingCall;
  final String? errorMessage;

  const CallState({
    required this.status,
    this.callHistory = const [],
    this.activeCall,
    this.incomingCall,
    this.errorMessage,
  });

  const CallState.initial()
    : status = CallUiStatus.initial,
      callHistory = const [],
      activeCall = null,
      incomingCall = null,
      errorMessage = null;

  CallState copyWith({
    CallUiStatus? status,
    List<CallLogEntity>? callHistory,
    ActiveCallEntity? activeCall,
    bool clearActiveCall = false,
    ActiveCallEntity? incomingCall,
    bool clearIncomingCall = false,
    String? errorMessage,
  }) {
    return CallState(
      status: status ?? this.status,
      callHistory: callHistory ?? this.callHistory,
      activeCall: clearActiveCall ? null : activeCall ?? this.activeCall,
      incomingCall: clearIncomingCall
          ? null
          : incomingCall ?? this.incomingCall,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    callHistory,
    activeCall,
    incomingCall,
    errorMessage,
  ];
}
