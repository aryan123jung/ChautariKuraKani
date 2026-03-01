import 'package:chautari_kurakani/features/report/domain/entities/report_entity.dart';
import 'package:flutter/material.dart';

Future<CreateReportParams?> showReportBottomSheet({
  required BuildContext context,
  required String title,
  String hintText = 'Describe what happened (optional)',
}) {
  return showModalBottomSheet<CreateReportParams>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReportBottomSheet(title: title, hintText: hintText),
  );
}

class _ReportBottomSheet extends StatefulWidget {
  final String title;
  final String hintText;

  const _ReportBottomSheet({required this.title, required this.hintText});

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  final TextEditingController _reasonTextController = TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();

  ReportReasonType _reasonType = ReportReasonType.spam;
  ReportPriority _priority = ReportPriority.medium;

  @override
  void dispose() {
    _reasonTextController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ReportReasonType>(
                initialValue: _reasonType,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                items: ReportReasonType.values
                    .map(
                      (r) => DropdownMenuItem<ReportReasonType>(
                        value: r,
                        child: Text(r.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _reasonType = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ReportPriority>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ReportPriority.values
                    .map(
                      (p) => DropdownMenuItem<ReportPriority>(
                        value: p,
                        child: Text(p.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _priority = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reasonTextController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Details',
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _evidenceController,
                decoration: const InputDecoration(
                  labelText: 'Evidence URL (optional)',
                  hintText: 'https://example.com/proof',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final evidence = _evidenceController.text.trim();
                        Navigator.pop(
                          context,
                          CreateReportParams(
                            reasonType: _reasonType,
                            priority: _priority,
                            reasonText: _reasonTextController.text.trim(),
                            evidenceUrls: evidence.isEmpty
                                ? const []
                                : [evidence],
                          ),
                        );
                      },
                      child: const Text('Submit Report'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
