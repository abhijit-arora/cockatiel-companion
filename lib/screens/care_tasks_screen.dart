import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/screens/create_task_screen.dart';

class CareTasksScreen extends StatefulWidget {
  const CareTasksScreen({super.key});

  @override
  State<CareTasksScreen> createState() => _CareTasksScreenState();
}

class _CareTasksScreenState extends State<CareTasksScreen> {
  String? _aviaryId;

  @override
  void initState() {
    super.initState();
    _determineAviaryId();
  }

  Future<void> _determineAviaryId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (mounted) {
      if (userDoc.exists && userDoc.data()!.containsKey('partOfAviary')) {
        setState(() => _aviaryId = userDoc.data()!['partOfAviary']);
      } else {
        setState(() => _aviaryId = user.uid);
      }
    }
  }

  Future<void> _markTaskAsComplete(String taskId, Map<String, dynamic> taskData) async {
    // This function needs the aviaryId to know which document to update
    if (_aviaryId == null) return;

    final DateTime nextDueDate = (taskData['nextDueDate'] as Timestamp).toDate();
    final DateTime now = DateTime.now();
    final bool isFutureTask = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day)
                                  .isAfter(DateTime(now.year, now.month, now.day));

    if (isFutureTask) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Completion'),
            content: const Text('This task is not due yet. Are you sure you want to mark it as complete ahead of schedule?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false), // Return false
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () => Navigator.of(context).pop(true), // Return true
              ),
            ],
          );
        },
      );

      // If the user did not confirm, stop the function here.
      if (confirmed != true) {
        return;
      }
    }

    // --- The original update logic remains the same ---
    final int recurrenceValue = taskData['recurrence_value'];
    final String recurrenceUnit = taskData['recurrence_unit'];
    DateTime newNextDueDate;

    // Calculate the next due date based on the *original* due date
    switch (recurrenceUnit) {
      case 'days': newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue)); break;
      case 'weeks': newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue * 7)); break;
      case 'months': newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue * 30)); break;
      default: return;
    }

    // Update the document in Firestore
    await FirebaseFirestore.instance
        .collection('aviaries').doc(_aviaryId)
        .collection('care_tasks').doc(taskId)
        .update({
      'lastCompletedDate': Timestamp.now(),
      'nextDueDate': Timestamp.fromDate(newNextDueDate),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () {
              if (_aviaryId != null) { // Only allow adding if we have an aviary context
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateTaskScreen(aviaryId: _aviaryId!)),
                );
              }
            },
          ),
        ],
      ),
      body: _aviaryId == null
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            // --- REVISED QUERY ---
            stream: FirebaseFirestore.instance
                .collection('aviaries').doc(_aviaryId) // <-- Use 'aviaries' and the aviaryId
                .collection('care_tasks')
                .orderBy('nextDueDate')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No care tasks scheduled.'));
              }
              final tasks = snapshot.data!.docs;
              final now = DateTime.now();

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final data = task.data() as Map<String, dynamic>;
                  final String title = data['title'] ?? 'Untitled Task';
                  final Timestamp? nextDueDateTs = data['nextDueDate'];
                  final DateTime? nextDueDate = nextDueDateTs?.toDate();
                  String status = 'Upcoming';
                  Color statusColor = Colors.green;
                  if (nextDueDate != null && nextDueDate.isBefore(now)) {
                    status = 'Overdue';
                    statusColor = Colors.red;
                  }
                  return ListTile(
                    leading: Icon(Icons.check_circle_outline, color: statusColor),
                    title: Text(title),
                    subtitle: Text(nextDueDate != null ? 'Due: ${DateFormat.yMMMMd().format(nextDueDate)} ($status)' : 'No due date set'),
                    onTap: () {
                      _markTaskAsComplete(task.id, data);
                    },
                  );
                },
              );
            },
          ),
    );
  }
}