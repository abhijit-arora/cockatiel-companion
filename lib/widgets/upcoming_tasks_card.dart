import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/screens/care_tasks_screen.dart';

class UpcomingTasksCard extends StatelessWidget {
  final String aviaryId;

  const UpcomingTasksCard({super.key, required this.aviaryId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      // Query for tasks that are due on or before today
      stream: FirebaseFirestore.instance
          .collection('aviaries')
          .doc(aviaryId)
          .collection('care_tasks')
          // Only get tasks where the due date is less than or equal to now
          .where('nextDueDate', isLessThanOrEqualTo: Timestamp.now())
          .orderBy('nextDueDate')
          .snapshots(),
      builder: (context, snapshot) {
        Widget cardContent;

        if (snapshot.connectionState == ConnectionState.waiting) {
          // It's good practice to handle the loading state inside the card
          cardContent = const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          cardContent = const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('All tasks are up to date!'),
            subtitle: Text('Tap to view all tasks'),
          );
        } else {
          final tasks = snapshot.data!.docs;
          // Build the card UI
          cardContent = Column( // <-- This is the content, no extra properties
            children: [
              const ListTile(
                title: Text('Tasks Due Today',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              // Create a compact list of the tasks
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(task['title']),
                    subtitle: Text(
                      'Due: ${DateFormat.yMMMMd().format((task['nextDueDate'] as Timestamp).toDate())}',
                    ),
                  );
                },
              ),
            ],
          );
        }
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CareTasksScreen()),
            );
          },
          child: Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 4.0,
            child: cardContent, // Use the content we determined above
          ),
        );
      },
    );
  }
}