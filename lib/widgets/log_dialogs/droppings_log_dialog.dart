import 'package:flutter/material.dart';

// Define the callback type
typedef OnSaveDroppingsLog = void Function({
  required String color,
  required String consistency,
  required String notes,
});

class DroppingsLogDialog extends StatefulWidget {
  final OnSaveDroppingsLog onSave;
  const DroppingsLogDialog({super.key, required this.onSave});

  @override
  State<DroppingsLogDialog> createState() => _DroppingsLogDialogState();
}

class _DroppingsLogDialogState extends State<DroppingsLogDialog> {
  String? _selectedColor;
  String? _selectedConsistency;
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Droppings Observation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color*'),
            Wrap(
              spacing: 8.0,
              children: ['Normal', 'Green', 'Yellow', 'Black', 'Red'].map((color) {
                return ChoiceChip(
                  label: Text(color),
                  selected: _selectedColor == color,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedColor = color);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            const Text('Consistency*'),
            Wrap(
              spacing: 8.0,
              children: ['Solid', 'Loose', 'Watery'].map((consistency) {
                return ChoiceChip(
                  label: Text(consistency),
                  selected: _selectedConsistency == consistency,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedConsistency = consistency);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            // Placeholder for Image upload
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photo (Optional)'),
              onPressed: () {
                // TODO: Implement image picking and upload logic
              },
            ),
            
            const SizedBox(height: 8),
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
            // Simple validation
            if (_selectedColor != null && _selectedConsistency != null) {
              widget.onSave(
                color: _selectedColor!,
                consistency: _selectedConsistency!,
                notes: _notesController.text,
              );
              Navigator.of(context).pop();
            } else {
              // Show a simple snackbar for error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select Color and Consistency.')),
              );
            }
          },
        ),
      ],
    );
  }
}