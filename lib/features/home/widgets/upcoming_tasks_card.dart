// lib/features/home/widgets/upcoming_tasks_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/features/care_tasks/screens/care_tasks_screen.dart';
import 'package:cockatiel_companion/core/constants.dart';

class UpcomingTasksCard extends StatelessWidget {
  final String aviaryId;

  const UpcomingTasksCard({super.key, required this.aviaryId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('aviaries')
          .doc(aviaryId)
          .collection('care_tasks')
          .where('nextDueDate', isLessThanOrEqualTo: Timestamp.now())
          .orderBy('nextDueDate')
          .snapshots(),
      builder: (context, snapshot) {
        Widget cardContent;

        if (snapshot.connectionState == ConnectionState.waiting) {
          cardContent = const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          cardContent = const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text(AppStrings.allTasksUpToDate),
            subtitle: Text(AppStrings.tapToViewAllTasks),
          );
        } else {
          final tasks = snapshot.data!.docs;
          cardContent = Column(
            children: [
              const ListTile(
                title: Text(Labels.tasksDueToday,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
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
                      '${Labels.due} ${DateFormat.yMMMMd().format((task['nextDueDate'] as Timestamp).toDate())}',
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
            child: cardContent,
          ),
        );
      },
    );
  }
}