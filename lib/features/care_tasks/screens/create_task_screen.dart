// lib/features/care_tasks/screens/create_task_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cockatiel_companion/core/constants.dart';

class CreateTaskScreen extends StatefulWidget {
  final String aviaryId;
  const CreateTaskScreen({super.key, required this.aviaryId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recurrenceValueController = TextEditingController(text: '7');
  String _selectedUnit = DropdownOptions.recurrenceUnits[0]; // Default to 'days'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.createNewCareTask),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: Labels.taskTitle,
                  hintText: AppStrings.taskTitleHint,
                ),
                validator: (value) => value!.isEmpty ? AppStrings.titleValidation : null,
              ),

              const SizedBox(height: 24),
              const Text(AppStrings.recurrencePrompt),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _recurrenceValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: Labels.recurrenceNumber),
                      validator: (value) => value!.isEmpty ? AppStrings.numberValidation : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      items: DropdownOptions.recurrenceUnits
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedUnit = value!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(Labels.appliesTo),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null) return;

                  try {
                    await FirebaseFirestore.instance
                        .collection('aviaries')
                        .doc(widget.aviaryId)
                        .collection('care_tasks')
                        .add({
                      'title': _titleController.text,
                      'recurrence_unit': _selectedUnit,
                      'recurrence_value': int.parse(_recurrenceValueController.text),
                      'lastCompletedDate': null,
                      'nextDueDate': DateTime.now(),
                      'birdIds': [],
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    
                    navigator.pop();

                  } catch (e) {
                    debugPrint('Error saving task: $e');
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('${AppStrings.failedToSaveTask}: $e')),
                    );
                  }
                },
                child: const Text(ButtonLabels.saveTask),
              ),
            ],
          ),
        ),
      ),
    );
  }
}