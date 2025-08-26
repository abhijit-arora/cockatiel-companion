import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Add New Nest' : 'Rename Nest'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nest Name*'),
          validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_formKey.currentState!.validate()) {
              final navigator = Navigator.of(context);
              setState(() { _isLoading = true; });
              await widget.onSave(_nameController.text.trim());
              navigator.pop();
            }
          },
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.0))
              : const Text('Save'),
        ),
      ],
    );
  }
}