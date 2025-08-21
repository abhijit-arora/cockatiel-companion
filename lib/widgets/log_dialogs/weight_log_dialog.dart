import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters

typedef OnSaveWeightLog = void Function({
  required double weight,
  required String unit,
  required String context,
  required String notes,
});

class WeightLogDialog extends StatefulWidget {
  final OnSaveWeightLog onSave;
  const WeightLogDialog({super.key, required this.onSave});

  @override
  State<WeightLogDialog> createState() => _WeightLogDialogState();
}

class _WeightLogDialogState extends State<WeightLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedUnit = 'g'; // Default to grams
  String? _selectedContext; // Default blank as requested

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Weight'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight*',
                  suffixText: _selectedUnit, // Shows g or oz
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a weight.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              // Simple Segmented Button for unit selection
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'g', label: Text('Grams')),
                  ButtonSegment(value: 'oz', label: Text('Ounces')),
                ],
                selected: {_selectedUnit},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedUnit = newSelection.first;
                  });
                },
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedContext,
                hint: const Text('Select Context (Optional)'),
                items: ['Before Meal', 'After Meal', 'Unspecified']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedContext = value;
                  });
                },
              ),

              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              ),
            ],
          ),
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
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                weight: double.parse(_weightController.text),
                unit: _selectedUnit,
                context: _selectedContext ?? 'Unspecified',
                notes: _notesController.text,
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}