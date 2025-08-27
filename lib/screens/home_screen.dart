import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/screens/aviary_management_screen.dart';
import 'package:cockatiel_companion/screens/profile_screen.dart';
import 'package:cockatiel_companion/screens/daily_log_screen.dart';
import 'package:cockatiel_companion/screens/knowledge_center_screen.dart';
import 'package:cockatiel_companion/screens/care_tasks_screen.dart';
import 'package:cockatiel_companion/screens/about_screen.dart';
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
            icon: const Icon(Icons.info_outline), // <-- Add this new button
            tooltip: 'About FlockWell',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutScreen()),
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
              
              // This StreamBuilder now handles fetching both nests and birds for clustering.
              Expanded(
                child: StreamBuilder<List<QuerySnapshot>>(
                  // Use StreamZip to listen to both nests and birds streams simultaneously.
                  stream: StreamZip([
                    FirebaseFirestore.instance.collection('aviaries').doc(_aviaryId).collection('nests').snapshots(),
                    FirebaseFirestore.instance.collection('birds').where('viewers', arrayContains: FirebaseAuth.instance.currentUser?.uid).snapshots(),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugPrint('Error loading home screen data: ${snapshot.error}');
                      return const Center(child: Text('Something went wrong!'));
                    }
                    if (!snapshot.hasData || snapshot.data!.length < 2) {
                      return const Center(child: Text('Loading data...'));
                    }

                    final nestsDocs = snapshot.data![0].docs;
                    final birdDocs = snapshot.data![1].docs;

                    if (birdDocs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('You have no birds yet. Add one to get started!', textAlign: TextAlign.center),
                        ),
                      );
                    }

                    // --- NEW LOGIC: Group birds by nest ID ---
                    final Map<String, List<DocumentSnapshot>> birdsByNest = {};
                    for (final birdDoc in birdDocs) {
                      final birdData = birdDoc.data() as Map<String, dynamic>;
                      final nestId = birdData['nestId'] as String?;
                      if (nestId != null) {
                        if (birdsByNest[nestId] == null) {
                          birdsByNest[nestId] = [];
                        }
                        birdsByNest[nestId]!.add(birdDoc);
                      }
                    }

                    // --- FIND ONBOARDING BIRD (Same logic, new placement) ---
                    DocumentSnapshot? onboardingBirdDoc;
                    for (final doc in birdDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data.containsKey('gotchaDay') && data['gotchaDay'] is Timestamp) {
                        if (onboardingBirdDoc == null) {
                          onboardingBirdDoc = doc;
                        } else {
                          final currentGotchaDay = (onboardingBirdDoc.data() as Map<String, dynamic>)['gotchaDay'] as Timestamp;
                          final newGotchaDay = data['gotchaDay'] as Timestamp;
                          if (newGotchaDay.compareTo(currentGotchaDay) > 0) {
                            onboardingBirdDoc = doc;
                          }
                        }
                      }
                    }
                    final bool hasOnboardingTip = onboardingBirdDoc != null;

                    // --- BUILD THE NEW CLUSTERED LIST ---
                    return ListView.builder(
                      itemCount: nestsDocs.length + (hasOnboardingTip ? 1 : 0),
                      itemBuilder: (context, index) {
                        // --- ONBOARDING TIP (if it exists) ---
                        if (hasOnboardingTip && index == 0) {
                          final onboardingData = onboardingBirdDoc!.data() as Map<String, dynamic>;
                          return OnboardingTipCard(
                            birdName: onboardingData['name'],
                            gotchaDay: onboardingData['gotchaDay'],
                          );
                        }

                        // Adjust index to account for the tip card
                        final nestIndex = hasOnboardingTip ? index - 1 : index;
                        if (nestIndex >= nestsDocs.length) return const SizedBox.shrink();

                        final nestDoc = nestsDocs[nestIndex];
                        final nestData = nestDoc.data() as Map<String, dynamic>;
                        final nestName = nestData['name'] ?? 'Unnamed Nest';
                        final birdsInThisNest = birdsByNest[nestDoc.id] ?? [];

                        if (birdsInThisNest.isEmpty) {
                          return const SizedBox.shrink(); // Don't show empty nests
                        }

                        // --- NEST HEADER AND BIRD LIST ---
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          elevation: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                child: Text(nestName, style: Theme.of(context).textTheme.titleLarge),
                              ),
                              const Divider(height: 1),
                              Column(
                                children: birdsInThisNest.map((birdDocument) {
                                  final birdData = birdDocument.data() as Map<String, dynamic>;
                                  final birdName = birdData['name'] as String;
                                  final birdId = birdDocument.id;

                                  // --- SUBTITLE CALCULATION LOGIC ---
                                  final String speciesText = birdData['species'] ?? '';
                                  final List<String> timeParts = [];

                                  if (birdData['hatchDay'] != null && birdData['hatchDay'] is Timestamp) {
                                    final hatchDay = (birdData['hatchDay'] as Timestamp).toDate();
                                    final now = DateTime.now();
                                    final ageInDays = now.difference(hatchDay).inDays;
                                    if (ageInDays >= 365) {
                                      final years = ageInDays ~/ 365;
                                      timeParts.add('$years year${years > 1 ? 's' : ''} old');
                                    } else if (ageInDays >= 30) {
                                      final months = ageInDays ~/ 30;
                                      timeParts.add('$months month${months > 1 ? 's' : ''} old');
                                    } else {
                                      timeParts.add('$ageInDays day${ageInDays != 1 ? 's' : ''} old');
                                    }
                                  }
                                  if (birdData['gotchaDay'] != null && birdData['gotchaDay'] is Timestamp) {
                                    final gotchaDay = (birdData['gotchaDay'] as Timestamp).toDate();
                                    final now = DateTime.now();
                                    final daysWithYou = now.difference(gotchaDay).inDays;
                                    if (daysWithYou >= 365) {
                                      final years = daysWithYou ~/ 365;
                                      timeParts.add('$years year${years > 1 ? 's' : ''} with you');
                                    } else if (daysWithYou >= 30) {
                                      final months = daysWithYou ~/ 30;
                                      timeParts.add('$months month${months > 1 ? 's' : ''} with you');
                                    } else {
                                      timeParts.add(daysWithYou == 0 ? 'New!' : '$daysWithYou day${daysWithYou != 1 ? 's' : ''} with you');
                                    }
                                  }
                                  final String timeText = timeParts.join(' • ');

                                  // --- Build the subtitle widget ---
                                  Widget? subtitleWidget;
                                  if (speciesText.isNotEmpty || timeText.isNotEmpty) {
                                    subtitleWidget = Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (speciesText.isNotEmpty) Text(speciesText),
                                        if (timeText.isNotEmpty) Text(timeText),
                                      ],
                                    );
                                  }

                                  return ListTile(
                                    leading: const Icon(Icons.star_border),
                                    title: Text(birdName),
                                    subtitle: subtitleWidget,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => DailyLogScreen(birdId: birdId, birdName: birdName),
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
                                }).toList(),
                              ),
                            ],
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