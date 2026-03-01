import 'package:equatable/equatable.dart';

enum ReportUiStatus { initial, submitting, success, error }

class ReportState extends Equatable {
  final ReportUiStatus status;
  final String? errorMessage;

  const ReportState({required this.status, this.errorMessage});

  const ReportState.initial()
    : status = ReportUiStatus.initial,
      errorMessage = null;

  ReportState copyWith({ReportUiStatus? status, String? errorMessage}) {
    return ReportState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
