import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';

class CreateReportApiModel {
  final String reasonType;
  final String priority;
  final String reasonText;
  final List<String> evidenceUrls;

  const CreateReportApiModel({
    required this.reasonType,
    required this.priority,
    required this.reasonText,
    required this.evidenceUrls,
  });

  factory CreateReportApiModel.fromParams(CreateReportParams params) {
    return CreateReportApiModel(
      reasonType: params.reasonType.value,
      priority: params.priority.value,
      reasonText: params.reasonText.trim(),
      evidenceUrls: params.evidenceUrls
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reasonType': reasonType,
      'priority': priority,
      'reasonText': reasonText,
      'evidenceUrls': evidenceUrls,
    };
  }
}
