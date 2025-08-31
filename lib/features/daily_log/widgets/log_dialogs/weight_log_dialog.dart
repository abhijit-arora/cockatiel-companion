// lib/features/daily_log/widgets/log_dialogs/weight_log_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cockatiel_companion/core/constants.dart';

typedef OnSaveWeightLog = Future<void> Function({
  required double weight,
  required String unit,
  required String context,
  required String notes,
});

class WeightLogDialog extends StatefulWidget {
  final OnSaveWeightLog onSave;
  final Map<String, dynamic>? initialData;

  const WeightLogDialog({
    super.key,
    required this.onSave,
    this.initialData
  });

  @override
  State<WeightLogDialog> createState() => _WeightLogDialogState();
}

class _WeightLogDialogState extends State<WeightLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedUnit = 'g';
  String? _selectedContext;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _weightController.text = (widget.initialData!['weight'] ?? 0.0).toString();
      _selectedUnit = widget.initialData!['unit'] ?? 'g';
      _selectedContext = widget.initialData!['context'];
      _notesController.text = widget.initialData!['notes'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ScreenTitles.logWeight),
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
                  labelText: Labels.weightRequired,
                  suffixText: _selectedUnit,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.weightValidation;
                  }
                  if (double.tryParse(value) == null) {
                    return AppStrings.validNumberValidation;
                  }
                  return null;
                },
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'g', label: Text(Labels.grams)),
                  ButtonSegment(value: 'oz', label: Text(Labels.ounces)),
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
                hint: const Text(AppStrings.selectContextHint),
                items: DropdownOptions.weightContexts
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
                decoration: const InputDecoration(labelText: Labels.notesOptional),
              ),
            ],
          ),
        ),
      ),
      actions: [
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
                weight: double.parse(_weightController.text),
                unit: _selectedUnit,
                context: _selectedContext ?? AppStrings.unspecifiedContext,
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