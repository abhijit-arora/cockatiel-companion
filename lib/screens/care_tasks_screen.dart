import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/screens/create_task_screen.dart';

class CareTasksScreen extends StatelessWidget {
  const CareTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Care Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query the care_tasks sub-collection for the current user
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('care_tasks')
            .orderBy('nextDueDate') // Sort by the nearest due date first
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
              
              // Determine the status and color
              String status = 'Upcoming';
              Color statusColor = Colors.green;
              if (nextDueDate != null && nextDueDate.isBefore(now)) {
                status = 'Overdue';
                statusColor = Colors.red;
              }

              return ListTile(
                leading: Icon(Icons.check_circle_outline, color: statusColor),
                title: Text(title),
                subtitle: Text(
                  nextDueDate != null
                      ? 'Due: ${DateFormat.yMMMMd().format(nextDueDate)} ($status)'
                      : 'No due date set',
                ),
                onTap: () {
                  _markTaskAsComplete(context, task.id, data);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markTaskAsComplete(BuildContext context, String taskId, Map<String, dynamic> taskData) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final DateTime nextDueDate = (taskData['nextDueDate'] as Timestamp).toDate();
    final DateTime now = DateTime.now();
    // Check if the task is due in the future (ignoring the time of day)
    final bool isFutureTask = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day)
                                .isAfter(DateTime(now.year, now.month, now.day));

    // --- NEW LOGIC: CONFIRMATION DIALOG ---
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
    // --- END OF NEW LOGIC ---

    // --- The original update logic remains the same ---
    final int recurrenceValue = taskData['recurrence_value'];
    final String recurrenceUnit = taskData['recurrence_unit'];
    DateTime newNextDueDate;

    // Calculate the next due date based on the *original* due date
    switch (recurrenceUnit) {
      case 'days':
        newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue));
        break;
      case 'weeks':
        newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue * 7));
        break;
      case 'months':
        newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue * 30));
        break;
      default:
        return;
    }

    // Update the document in Firestore
    await FirebaseFirestore.instance
        .collection('users').doc(userId)
        .collection('care_tasks').doc(taskId)
        .update({
      'lastCompletedDate': Timestamp.now(),
      'nextDueDate': Timestamp.fromDate(newNextDueDate),
    });
  }
}