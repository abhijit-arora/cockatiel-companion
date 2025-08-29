import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChirpDetailScreen extends StatefulWidget {
  final String chirpId;

  const ChirpDetailScreen({super.key, required this.chirpId});

  @override
  State<ChirpDetailScreen> createState() => _ChirpDetailScreenState();
}

class _ChirpDetailScreenState extends State<ChirpDetailScreen> {
  final _replyController = TextEditingController();
  bool _isReplying = false;

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isReplying = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in
      setState(() => _isReplying = false);
      return;
    }

    try {
      final chirpRef = FirebaseFirestore.instance.collection('community_chirps').doc(widget.chirpId);

      // We need the user's current author label
      // NOTE: This duplicates logic from CreateChirpScreen. In a future refactor,
      // we could move this into a dedicated UserService.
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String aviaryId = userDoc.exists && userDoc.data()!.containsKey('partOfAviary')
          ? userDoc.data()!['partOfAviary']
          : user.uid;
      final aviaryDoc = await FirebaseFirestore.instance.collection('aviaries').doc(aviaryId).get();
      final aviaryName = aviaryDoc.data()?['aviaryName'] ?? 'An Aviary';
      final isGuardian = !(userDoc.exists && userDoc.data()!.containsKey('partOfAviary'));
      String userLabel;
      if (isGuardian) {
        userLabel = aviaryDoc.data()?['guardianLabel'] ?? user.email ?? 'Guardian';
      } else {
        final caregiverDoc = await FirebaseFirestore.instance.collection('aviaries').doc(aviaryId).collection('caregivers').doc(user.uid).get();
        userLabel = caregiverDoc.data()?['label'] ?? user.email ?? 'Caregiver';
      }
      final authorLabel = '$userLabel of $aviaryName';


      // Add the reply to the subcollection
      await chirpRef.collection('replies').add({
        'body': _replyController.text.trim(),
        'authorId': user.uid,
        'authorLabel': authorLabel,
        'createdAt': FieldValue.serverTimestamp(),
        'helpfulCount': 0,
      });

      // Use a transaction to safely increment the reply count
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(chirpRef, {
          'replyCount': FieldValue.increment(1),
        });
      });

      _replyController.clear();

    } catch (e) {
      debugPrint('Error posting reply: $e');
    } finally {
      if (mounted) {
        setState(() => _isReplying = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chirp'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // --- SLIVER 1: THE MAIN CHIRP CONTENT ---
                SliverToBoxAdapter(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('community_chirps').doc(widget.chirpId).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator()));
                      }
                      if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text('Chirp not found.'));
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final String title = data['title'] ?? 'No Title';
                      final String body = data['body'] ?? '';
                      final String authorLabel = data['authorLabel'] ?? 'Anonymous';
                      final String? mediaUrl = data['mediaUrl'];
                      final Timestamp? timestamp = data['createdAt'];

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text('Posted by $authorLabel'),
                            if (timestamp != null)
                              Text(DateFormat.yMMMd().add_jm().format(timestamp.toDate()), style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 16),

                            // --- RE-ORDERED MEDIA AND BODY ---
                            if (mediaUrl != null && mediaUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(mediaUrl, width: double.infinity, fit: BoxFit.cover),
                                ),
                              ),
                            if (body.isNotEmpty) 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0), // Add padding for spacing
                                child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
                              ),
                            
                            const Divider(height: 24), // Adjusted spacing
                            Text('Replies', style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // --- SLIVER 2: THE REPLIES LIST ---
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('community_chirps').doc(widget.chirpId).collection('replies').orderBy('createdAt').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Be the first to reply!'),
                      )));
                    }

                    final replies = snapshot.data!.docs;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final data = replies[index].data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              title: Text(data['body'] ?? ''),
                              subtitle: Text('by ${data['authorLabel'] ?? 'Anonymous'}'),
                            ),
                          );
                        },
                        childCount: replies.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // --- REPLY INPUT FIELD ---
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: 'Add a reply...',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isReplying ? null : _postReply,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}