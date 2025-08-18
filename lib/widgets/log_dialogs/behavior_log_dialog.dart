import 'package:flutter/material.dart';

// Define the callback type
typedef OnSaveBehaviorLog = void Function({
  required List<String> behaviors,
  required String mood,
  required String notes,
});

class BehaviorLogDialog extends StatefulWidget {
  final OnSaveBehaviorLog onSave;
  const BehaviorLogDialog({super.key, required this.onSave});

  @override
  State<BehaviorLogDialog> createState() => _BehaviorLogDialogState();
}

class _BehaviorLogDialogState extends State<BehaviorLogDialog> {
  // Use a Set for behaviors to automatically handle duplicates
  final Set<String> _selectedBehaviors = {};
  String? _selectedMood;
  final _notesController = TextEditingController();

  final List<String> _commonBehaviors = [
    'Chirping', 'Singing', 'Preening', 'Stretching', 'Foraging', 'Playing', 'Napping'
  ];
  final List<String> _moods = ['Happy', 'Calm', 'Playful', 'Anxious', 'Grumpy', 'Quiet'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Behavior & Mood'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Behaviors (select all that apply)'),
            Wrap(
              spacing: 8.0,
              children: _commonBehaviors.map((behavior) {
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
            const Text('Overall Mood*'),
            Wrap(
              spacing: 8.0,
              children: _moods.map((mood) {
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
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (_selectedMood != null) {
              widget.onSave(
                // Convert the Set to a List for saving
                behaviors: _selectedBehaviors.toList(),
                mood: _selectedMood!,
                notes: _notesController.text,
              );
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an Overall Mood.')),
              );
            }
          },
        ),
      ],
    );
  }
}