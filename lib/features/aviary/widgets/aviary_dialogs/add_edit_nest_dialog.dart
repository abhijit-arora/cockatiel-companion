// lib/features/aviary/widgets/aviary_dialogs/add_edit_nest_dialog.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

typedef OnSaveNest = Future<void> Function(String name);

class AddEditNestDialog extends StatefulWidget {
  final OnSaveNest onSave;
  final String? initialName; // For editing

  const AddEditNestDialog({super.key, required this.onSave, this.initialName});

  @override
  State<AddEditNestDialog> createState() => _AddEditNestDialogState();
}

class _AddEditNestDialogState extends State<AddEditNestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the generic AppStrings.enclosure constant in the titles.
    final titleText = widget.initialName == null
        ? ScreenTitles.addNewEnclosure
        : ScreenTitles.renameEnclosure;

    return AlertDialog(
      title: Text(titleText),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: Labels.enclosureRequired),
          validator: (value) =>
              value!.isEmpty ? AppStrings.nameValidation : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(ButtonLabels.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final navigator = Navigator.of(context);
                    setState(() {
                      _isLoading = true;
                    });
                    await widget.onSave(_nameController.text.trim());
                    navigator.pop();
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.0))
              : const Text(ButtonLabels.save),
        ),
      ],
    );
  }
}