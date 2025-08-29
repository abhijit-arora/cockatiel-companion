import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateTaskScreen extends StatefulWidget {
  final String aviaryId;
  const CreateTaskScreen({super.key, required this.aviaryId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recurrenceValueController = TextEditingController(text: '7'); // Default to 7
  String _selectedUnit = 'days'; // Default to 'days'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Care Task'),
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
                  labelText: 'Task Title*',
                  hintText: 'e.g., Weekly Cage Deep Clean',
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 24),
              const Text('This task repeats every...'),
              Row(
                children: [
                  // --- RECURRENCE VALUE INPUT ---
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _recurrenceValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Number*'),
                      validator: (value) => value!.isEmpty ? 'Enter a number' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // --- RECURRENCE UNIT SELECTOR ---
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      items: ['days', 'weeks', 'months']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedUnit = value!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // We will implement the bird selector later
              const Text('Applies to: All Birds (for now)'),

              const SizedBox(height: 32),
              // --- SAVE BUTTON ---
              ElevatedButton(
                onPressed: () async {
                  // First, validate the form. If it's not valid, do nothing.
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  // --- NEW: Capture context-dependent objects BEFORE the async gap ---
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  // --- END OF NEW CODE ---

                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null) return;

                  try {
                    // THE ASYNC GAP: This is where the "await" happens.
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

                    // --- Use the captured objects AFTER the async gap ---
                    navigator.pop();

                  } catch (e) {
                    print('Error saving task: $e');
                    // Use the captured object
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Failed to save task: $e')),
                    );
                  }
                },
                child: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}