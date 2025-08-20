import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _recurrenceValueController = TextEditingController(text: '7'); // Default to 7
  String _selectedUnit = 'days'; // Default to 'days'
  DateTime _selectedStartDate = DateTime.now();

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
                      value: _selectedUnit,
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
                onPressed: () async { // <-- Make the function async
                  if (_formKey.currentState!.validate()) {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId == null) return; // Should not happen

                    try {
                      // Add the new task to the user's care_tasks sub-collection
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('care_tasks')
                          .add({
                        'title': _titleController.text,
                        'recurrence_unit': _selectedUnit,
                        'recurrence_value': int.parse(_recurrenceValueController.text),
                        'lastCompletedDate': null,
                        // For now, the first due date is today. We can add a date picker later.
                        'nextDueDate': DateTime.now(),
                        'birdIds': [], // For now, applies to all birds implicitly
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      // Go back to the previous screen after saving
                      if (mounted) Navigator.of(context).pop();

                    } catch (e) {
                      print('Error saving task: $e');
                      // Show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save task: $e')),
                      );
                    }
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