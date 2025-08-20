import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/screens/profile_screen.dart';
import 'package:cockatiel_companion/screens/daily_log_screen.dart';
import 'package:cockatiel_companion/screens/knowledge_center_screen.dart';
import 'package:cockatiel_companion/screens/care_tasks_screen.dart';
import 'package:cockatiel_companion/widgets/onboarding_tip_card.dart';
import 'package:cockatiel_companion/widgets/upcoming_tasks_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            // The logo with a white circular background
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20, // Controls the size of the circle
              child: Padding(
                padding: const EdgeInsets.all(4.0), // Adds a little space around the logo
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            const SizedBox(width: 10), // A little space
            // The text title
            const Text('Your Flock'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.task_alt),
            tooltip: 'Care Tasks',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CareTasksScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.library_books),
            tooltip: 'Knowledge Center',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const KnowledgeCenterScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Define the query to fetch the bird profile
        stream: FirebaseFirestore.instance
            .collection('birds')
            .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // --- 1. Handle Loading State ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 2. Handle Error State ---
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          // --- 3. Handle "No Data" State ---
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have no birds yet. Add one!'),
            );
          }

          // --- 4. Handle "Has Data" State ---
          // If we get here, it means we have data!
          final birdDocs = snapshot.data!.docs;

          // Sort the documents by creation date to get the first bird reliably
          birdDocs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final Timestamp aTs = aData['createdAt'] ?? Timestamp.now();
            final Timestamp bTs = bData['createdAt'] ?? Timestamp.now();
            return aTs.compareTo(bTs); // Ascending order
          });

          final mainBirdDocData = birdDocs.first.data() as Map<String, dynamic>;
          Timestamp? gotchaDayTimestamp;

          // Safely get the timestamp from the first bird's data
          if (mainBirdDocData.containsKey('gotchaDay') && mainBirdDocData['gotchaDay'] is Timestamp) {
            gotchaDayTimestamp = mainBirdDocData['gotchaDay'] as Timestamp;
          }

          return Column(
            children: [
              // --- ONBOARDING TIP CARD ---
              if (gotchaDayTimestamp != null)
                OnboardingTipCard(birdName: mainBirdDocData['name'],gotchaDay: gotchaDayTimestamp),
              const UpcomingTasksCard(),
              // --- BIRD LIST ---
              Expanded(
                child: ListView.builder(
                  itemCount: birdDocs.length,
                  itemBuilder: (context, index) {
                    final birdDocument = birdDocs[index];
                    final birdData = birdDocument.data() as Map<String, dynamic>;
                    final birdName = birdData['name'] as String;
                    final birdId = birdDocument.id;

                    return ListTile(
                      leading: const Icon(Icons.star_border),
                      title: Text(birdName),
                      // PRIMARY ACTION: Tapping anywhere on the tile goes to the log
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DailyLogScreen(
                              birdId: birdId,
                              birdName: birdName,
                            ),
                          ),
                        );
                      },
                      // SECONDARY ACTION: An explicit button for editing
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(birdId: birdId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}