import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/screens/aviary_management_screen.dart';
import 'package:cockatiel_companion/screens/profile_screen.dart';
import 'package:cockatiel_companion/screens/daily_log_screen.dart';
import 'package:cockatiel_companion/screens/knowledge_center_screen.dart';
import 'package:cockatiel_companion/screens/care_tasks_screen.dart';
import 'package:cockatiel_companion/widgets/onboarding_tip_card.dart';
import 'package:cockatiel_companion/widgets/upcoming_tasks_card.dart';
import 'package:cockatiel_companion/widgets/pending_invitations_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _aviaryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determineAviaryId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Your Flock'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_work_outlined),
            tooltip: 'Manage Aviary',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AviaryManagementScreen()),
              );
            },
          ),
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
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // These two cards are always present after loading
              const PendingInvitationsCard(),
              if (_aviaryId != null) UpcomingTasksCard(aviaryId: _aviaryId!),

              // This StreamBuilder now ONLY handles the bird list or "no birds" text
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('birds')
                    .where('viewers', arrayContains: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong!'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('You have no birds yet. Add one to get started!', textAlign: TextAlign.center),
                      ),
                    );
                  }

                  // --- Handle "Has Birds" State ---
                  final birdDocs = snapshot.data!.docs;
                  birdDocs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final Timestamp aTs = aData['createdAt'] ?? Timestamp.now();
                    final Timestamp bTs = bData['createdAt'] ?? Timestamp.now();
                    return aTs.compareTo(bTs);
                  });

                  final mainBirdDocData = birdDocs.first.data() as Map<String, dynamic>;
                  Timestamp? gotchaDayTimestamp;
                  if (mainBirdDocData.containsKey('gotchaDay') && mainBirdDocData['gotchaDay'] is Timestamp) {
                    gotchaDayTimestamp = mainBirdDocData['gotchaDay'] as Timestamp;
                  }

                  return ListView.builder(
                    itemCount: birdDocs.length + 1, // +1 for the tip card
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // First item is the tip card
                        if (gotchaDayTimestamp != null) {
                          return OnboardingTipCard(
                            birdName: mainBirdDocData['name'],
                            gotchaDay: gotchaDayTimestamp,
                          );
                        }
                        return const SizedBox.shrink(); // No tip if no date
                      }
                      
                      // The rest are the bird list tiles
                      final birdDocument = birdDocs[index - 1]; // -1 to adjust for tip card
                      final birdData = birdDocument.data() as Map<String, dynamic>;
                      final birdName = birdData['name'] as String;
                      final birdId = birdDocument.id;

                      return ListTile(
                        leading: const Icon(Icons.star_border),
                        title: Text(birdName),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(birdId: birdId, aviaryId: _aviaryId!),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProfileScreen(aviaryId: _aviaryId!)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _determineAviaryId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data()!.containsKey('partOfAviary')) {
      // This user is a CAREGIVER in someone else's Aviary
      setState(() {
        _aviaryId = userDoc.data()!['partOfAviary'];
        _isLoading = false;
      });
    } else {
      // This user is a GUARDIAN of their own Aviary
      setState(() {
        _aviaryId = user.uid;
        _isLoading = false;
      });
    }
  }
}