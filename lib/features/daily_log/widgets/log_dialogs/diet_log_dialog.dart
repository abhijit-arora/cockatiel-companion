// lib/features/daily_log/widgets/log_dialogs/diet_log_dialog.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

typedef OnSaveDietLog = Future<void> Function({
  required String foodType,
  required String description,
  required String consumptionLevel,
  required String notes,
});

class DietLogDialog extends StatefulWidget {
  final OnSaveDietLog onSave;
  final Map<String, dynamic>? initialData;

  const DietLogDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<DietLogDialog> createState() => _DietLogDialogState();
}

class _DietLogDialogState extends State<DietLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedFoodType;
  String? _consumptionLevel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedFoodType = widget.initialData!['foodType'];
      _descriptionController.text = widget.initialData!['description'];
      _consumptionLevel = widget.initialData!['consumptionLevel'];
      _notesController.text = widget.initialData!['notes'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ScreenTitles.logFoodOffered),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                initialValue: _selectedFoodType,
                hint: const Text(AppStrings.selectFoodTypeHint),
                items: DropdownOptions.dietFoodTypes
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFoodType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: Labels.foodType),
                validator: (value) => value == null ? AppStrings.foodTypeValidation : null,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: Labels.description),
              ),
              const SizedBox(height: 16),
              const Text(Labels.consumptionLevel),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        // Note: The order in the constant is 'Ate Well', 'Ate Some', 'Untouched'.
                        // Reversing it for the desired UI layout.
                        children: DropdownOptions.dietConsumptionLevels.reversed.map((level) {
                          return ChoiceChip(
                            label: Text(level),
                            selected: _consumptionLevel == level,
                            selectedColor: Theme.of(context).primaryColorLight,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _consumptionLevel = level;
                                  state.didChange(level);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      if (state.hasError)
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
                    return AppStrings.consumptionLevelValidation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: Labels.notesOptional),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(ButtonLabels.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_formKey.currentState!.validate()) {
              final navigator = Navigator.of(context);
              setState(() { _isLoading = true; });

              await widget.onSave(
                foodType: _selectedFoodType!,
                description: _descriptionController.text,
                consumptionLevel: _consumptionLevel!,
                notes: _notesController.text,
              );

              navigator.pop();
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