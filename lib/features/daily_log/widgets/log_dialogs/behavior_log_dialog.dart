// lib/features/daily_log/widgets/log_dialogs/behavior_log_dialog.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

typedef OnSaveBehaviorLog = Future<void> Function({
  required List<String> behaviors,
  required String mood,
  required String notes,
});

class BehaviorLogDialog extends StatefulWidget {
  final OnSaveBehaviorLog onSave;
  final Map<String, dynamic>? initialData;

  const BehaviorLogDialog({
    super.key,
    required this.onSave,
    this.initialData
  });

  @override
  State<BehaviorLogDialog> createState() => _BehaviorLogDialogState();
}

class _BehaviorLogDialogState extends State<BehaviorLogDialog> {
  final Set<String> _selectedBehaviors = {};
  String? _selectedMood;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final List<dynamic> behaviors = widget.initialData!['behaviors'] ?? [];
      _selectedBehaviors.addAll(behaviors.map((b) => b.toString()));
      _selectedMood = widget.initialData!['mood'];
      _notesController.text = widget.initialData!['notes'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ScreenTitles.logBehaviorAndMood),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(Labels.behaviors),
            Wrap(
              spacing: 8.0,
              children: DropdownOptions.commonBehaviors.map((behavior) {
                return FilterChip(
                  label: Text(behavior),
                  selected: _selectedBehaviors.contains(behavior),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedBehaviors.add(behavior);
                      } else {
                        _selectedBehaviors.remove(behavior);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            const Text(Labels.overallMood),
            Wrap(
              spacing: 8.0,
              children: DropdownOptions.moods.map((mood) {
                return ChoiceChip(
                  label: Text(mood),
                  selected: _selectedMood == mood,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMood = mood);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: Labels.notesOptional),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(ButtonLabels.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_selectedMood != null) {
              final navigator = Navigator.of(context);
              setState(() { _isLoading = true; });

              await widget.onSave(
                behaviors: _selectedBehaviors.toList(),
                mood: _selectedMood!,
                notes: _notesController.text,
              );
              
              navigator.pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.moodValidation)),
              );
            }
          },
          child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
              )
            : const Text(ButtonLabels.save),
        ),
      ],
    );
  }
}