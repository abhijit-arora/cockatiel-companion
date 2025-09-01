// lib/features/community/widgets/dialogs/report_dialog.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

// Callback to pass the selected reason back
typedef OnSubmitReport = void Function(String reason);

class ReportDialog extends StatefulWidget {
  final String title;
  final OnSubmitReport onSubmit;

  const ReportDialog({
    super.key,
    required this.title,
    required this.onSubmit,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(Labels.reasonForReport),
          const SizedBox(height: 8),
          // We use a DropdownButton for the list of reasons
          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            hint: const Text('Select a reason...'), // This won't be themed for now
            isExpanded: true,
            items: DropdownOptions.reportReasons.map((String reason) {
              return DropdownMenuItem<String>(
                value: reason,
                child: Text(reason),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedReason = newValue;
              });
            },
            validator: (value) => value == null ? 'Please select a reason' : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(ButtonLabels.cancel),
        ),
        ElevatedButton(
          // Disable the button until a reason is selected
          onPressed: _selectedReason == null
              ? null
              : () {
                  widget.onSubmit(_selectedReason!);
                  Navigator.of(context).pop();
                },
          child: const Text(ButtonLabels.submitReport),
        ),
      ],
    );
  }
}