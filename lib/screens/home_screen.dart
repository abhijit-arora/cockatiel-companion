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
import 'package:cockatiel_companion/widgets/upcoming_anniversary_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class UpcomingAnniversary {
  final String birdName;
  final String eventName;
  final int daysRemaining;

  UpcomingAnniversary({
    required this.birdName,
    required this.eventName,
    required this.daysRemaining,
  });
}

class _HomePageState extends State<HomePage> {
  String? _aviaryId;
  bool _isLoading = true;
  final Set<String> _dismissedAnniversaries = {};

  @override
  void initState() {
    super.initState();
    _determineAviaryId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title no longer needs the inversePrimary color from the theme
        // as it will match the new app bars on the other screens.
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
          // Keep the most important action directly visible.
          IconButton(
            icon: const Icon(Icons.group_work_outlined),
            tooltip: 'Manage Aviary',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AviaryManagementScreen()),
              );
            },
          ),
          // Use a PopupMenuButton for all other actions.
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'care_tasks':
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CareTasksScreen()));
                  break;
                case 'knowledge_center':
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const KnowledgeCenterScreen()));
                  break;
                case 'about':
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutScreen()));
                  break;
                case 'sign_out':
                  FirebaseAuth.instance.signOut();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'care_tasks',
                child: ListTile(
                  leading: Icon(Icons.task_alt),
                  title: Text('Care Tasks'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'knowledge_center',
                child: ListTile(
                  leading: Icon(Icons.library_books),
                  title: Text('Knowledge Center'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About FlockWell'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'sign_out',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async {
              // This triggers a rebuild, which re-creates the stream with fresh data.
              setState(() {});
              // Add a small delay for better UX so the indicator is visible briefly.
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Column(
              children: [
                // These two cards are always present after loading
                const PendingInvitationsCard(),
                if (_aviaryId != null) UpcomingTasksCard(aviaryId: _aviaryId!),
                
                // This StreamBuilder now handles fetching both nests and birds for clustering.
                Expanded(
                  child: StreamBuilder<List<QuerySnapshot>>(
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

                      // --- LOGIC TO FIND UPCOMING ANNIVERSARIES ---
                      final List<UpcomingAnniversary> upcomingAnniversaries = [];
                      final today = DateTime.now();
                      const int notificationWindow = 7;

                      for (final birdDoc in birdDocs) {
                        final birdData = birdDoc.data() as Map<String, dynamic>;
                        final birdName = birdData['name'] as String;

                        void checkAnniversary(String eventName, Timestamp? eventTimestamp) {
                          if (eventTimestamp == null) return;
                          final eventDate = eventTimestamp.toDate();
                          // Use a date-only comparison to avoid time-of-day issues
                          final todayDateOnly = DateTime(today.year, today.month, today.day);
                          DateTime nextAnniversary = DateTime(today.year, eventDate.month, eventDate.day);

                          if (nextAnniversary.isBefore(todayDateOnly)) {
                            nextAnniversary = DateTime(today.year + 1, eventDate.month, eventDate.day);
                          }
                          
                          // Use .difference().inDays, which is correct for this
                          final daysRemaining = nextAnniversary.difference(todayDateOnly).inDays;
                          
                          if (daysRemaining >= 0 && daysRemaining <= notificationWindow) {
                            upcomingAnniversaries.add(UpcomingAnniversary(
                                birdName: birdName, eventName: eventName, daysRemaining: daysRemaining));
                          }
                        }
                        checkAnniversary('Hatch Day', birdData['hatchDay']);
                        checkAnniversary('Gotcha Day', birdData['gotchaDay']);
                      }
                      // Sort events by days remaining
                      upcomingAnniversaries.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));


                      // --- LOGIC TO GROUP BIRDS BY NEST ---
                      final Map<String, List<DocumentSnapshot>> birdsByNest = {};
                      for (final birdDoc in birdDocs) {
                        final birdData = birdDoc.data() as Map<String, dynamic>;
                        final nestId = birdData['nestId'] as String?;
                        if (nestId != null) {
                          birdsByNest.putIfAbsent(nestId, () => []).add(birdDoc);
                        }
                      }

                      // --- LOGIC TO FIND ONBOARDING BIRD ---
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
                      
                      final List<UpcomingAnniversary> activeAnniversaries = upcomingAnniversaries.where((event) {
                        // Create a unique ID for each anniversary instance.
                        final eventId = '${event.birdName}-${event.eventName}';
                        return !_dismissedAnniversaries.contains(eventId);
                      }).toList();

                      // --- Update the counts based on the filtered list ---
                      final int anniversaryCount = activeAnniversaries.length;
                      final int tipCount = hasOnboardingTip ? 1 : 0;

                      return ListView.builder(
                        itemCount: tipCount + anniversaryCount + nestsDocs.length,
                        itemBuilder: (context, index) {
                          // --- SECTION 1: ONBOARDING TIP ---
                          if (hasOnboardingTip && index == 0) {
                            final onboardingData = onboardingBirdDoc!.data() as Map<String, dynamic>;
                            return OnboardingTipCard(
                              birdName: onboardingData['name'],
                              gotchaDay: onboardingData['gotchaDay'],
                            );
                          }

                          // --- SECTION 2: ANNIVERSARY CARDS ---
                          if (index < (tipCount + anniversaryCount)) {
                            final anniversaryIndex = index - tipCount;
                            final event = activeAnniversaries[anniversaryIndex];
                            final eventId = '${event.birdName}-${event.eventName}';

                            return Dismissible(
                              key: Key(eventId), // Unique key is essential!
                              onDismissed: (direction) {
                                setState(() {
                                  _dismissedAnniversaries.add(eventId);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${event.birdName}\'s reminder dismissed.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              background: Container(
                                color: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: const Icon(Icons.check, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.delete_forever, color: Colors.white),
                              ),
                              child: UpcomingAnniversaryCard(
                                birdName: event.birdName,
                                eventName: event.eventName,
                                daysRemaining: event.daysRemaining,
                              ),
                            );
                          }

                          // --- SECTION 3: NEST CLUSTERS ---
                          final nestIndex = index - tipCount - anniversaryCount;
                          if (nestIndex >= nestsDocs.length) return const SizedBox.shrink();

                          final nestDoc = nestsDocs[nestIndex];
                          final nestData = nestDoc.data() as Map<String, dynamic>;
                          final nestName = nestData['name'] ?? 'Unnamed Nest';
                          final birdsInThisNest = birdsByNest[nestDoc.id] ?? [];

                          if (birdsInThisNest.isEmpty) {
                            return const SizedBox.shrink();
                          }

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
                                          onPressed: () async { // <-- Make async
                                            // Await the result of the ProfileScreen
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => ProfileScreen(birdId: birdId, aviaryId: _aviaryId!),
                                              ),
                                            );
                                            // When we return, force a rebuild.
                                            setState(() {});
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