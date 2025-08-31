// lib/features/care_tasks/screens/care_tasks_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/features/care_tasks/screens/create_task_screen.dart';
import 'package:cockatiel_companion/core/constants.dart';

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
            title: const Text(ScreenTitles.confirmCompletion),
            content: const Text(AppStrings.confirmEarlyCompletion),
            actions: <Widget>[
              TextButton(
                child: const Text(ButtonLabels.cancel),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text(ButtonLabels.confirm),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }
    }

    final int recurrenceValue = taskData['recurrence_value'];
    final String recurrenceUnit = taskData['recurrence_unit'];
    DateTime newNextDueDate;

    switch (recurrenceUnit) {
      case 'days': newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue)); break;
      case 'weeks': newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue * 7)); break;
      case 'months': newNextDueDate = nextDueDate.add(Duration(days: recurrenceValue * 30)); break;
      default: return;
    }

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
        title: const Text(ScreenTitles.careTasks),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () {
              if (_aviaryId != null) {
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
            stream: FirebaseFirestore.instance
                .collection('aviaries').doc(_aviaryId)
                .collection('care_tasks')
                .orderBy('nextDueDate')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text(AppStrings.noCareTasks));
              }
              final tasks = snapshot.data!.docs;
              final now = DateTime.now();

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final data = task.data() as Map<String, dynamic>;
                  final String title = data['title'] ?? AppStrings.untitledTask;
                  final Timestamp? nextDueDateTs = data['nextDueDate'];
                  final DateTime? nextDueDate = nextDueDateTs?.toDate();
                  String status = AppStrings.taskStatusUpcoming;
                  Color statusColor = Colors.green;
                  if (nextDueDate != null && nextDueDate.isBefore(now)) {
                    status = AppStrings.taskStatusOverdue;
                    statusColor = Colors.red;
                  }
                  return ListTile(
                    leading: Icon(Icons.check_circle_outline, color: statusColor),
                    title: Text(title),
                    subtitle: Text(nextDueDate != null ? '${Labels.due} ${DateFormat.yMMMMd().format(nextDueDate)} ($status)' : AppStrings.noDueDate),
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