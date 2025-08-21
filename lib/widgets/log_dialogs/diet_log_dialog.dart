import 'package:flutter/material.dart';

// Define a type for our callback function for clarity
typedef OnSaveDietLog = void Function({
  required String foodType,
  required String description,
  required String consumptionLevel,
  required String notes,
});

class DietLogDialog extends StatefulWidget {
  // Add the callback function as a required parameter
  final OnSaveDietLog onSave;

  const DietLogDialog({super.key, required this.onSave});

  @override
  State<DietLogDialog> createState() => _DietLogDialogState();
}

class _DietLogDialogState extends State<DietLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedFoodType; // Default
  String? _consumptionLevel; // Default

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Food Offered'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Dropdown for Food Type
              DropdownButtonFormField<String>(
                initialValue: _selectedFoodType,
                hint: const Text('Select Food Type'),
                items: ['Pellets', 'Green Leafs', 'Vegetables', 'Fruit', 'Sprouts', 'Treat', 'Other']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFoodType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Food Type'),
                validator: (value) => value == null ? 'Please select a food type.' : null,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (e.g., Fresh chop)'),
              ),
              const SizedBox(height: 16),
              const Text('Consumption Level*'), // Add asterisk for mandatory
              // Use a FormField to handle validation for the ChoiceChips
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        children: ['Untouched', 'Ate Some', 'Ate Well'].map((level) {
                          return ChoiceChip(
                            label: Text(level),
                            selected: _consumptionLevel == level,
                            selectedColor: Theme.of(context).primaryColorLight, // <-- Better visual
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _consumptionLevel = level;
                                  state.didChange(level); // Notify the FormField
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      if (state.hasError) // <-- Show error text if invalid
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
                validator: (value) {
                  if (_consumptionLevel == null) {
                    return 'Please select a consumption level.';
                  }
                  return null;
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
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                foodType: _selectedFoodType!,
                description: _descriptionController.text,
                consumptionLevel: _consumptionLevel!,
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