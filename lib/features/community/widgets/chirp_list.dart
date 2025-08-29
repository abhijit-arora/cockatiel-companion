import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/screens/chirp_detail_screen.dart';

// 1. CONVERTED TO A STATEFUL WIDGET
class ChirpList extends StatefulWidget {
  final String category;
  const ChirpList({super.key, required this.category});

  @override
  State<ChirpList> createState() => _ChirpListState();
}

class _ChirpListState extends State<ChirpList> {
  // 2. ADDED STATE VARIABLE FOR INSTANT UI FEEDBACK
  final Set<String> _locallyUpvotedChirps = {};

  @override
  Widget build(BuildContext context) {
    // 3. MOVED BUILD LOGIC INTO THE STATE CLASS
    Query query = FirebaseFirestore.instance
        .collection('community_chirps')
        .orderBy('createdAt', descending: true);

    if (widget.category != 'All Chirps') {
      query = query.where('category', isEqualTo: widget.category);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No chirps in this category yet. Be the first to post!',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final chirps = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chirps.length,
          itemBuilder: (context, index) {
            final chirp = chirps[index];
            final data = chirp.data() as Map<String, dynamic>;

            final String title = data['title'] ?? 'No Title';
            final String authorLabel = data['authorLabel'] ?? 'Anonymous';
            final int replyCount = data['replyCount'] ?? 0;
            final int upvoteCount = data['upvoteCount'] ?? 0;
            final String? mediaUrl = data['mediaUrl'];

            // 4. CHECK IF THE CHIRP HAS BEEN LOCALLY UPVOTED
            final bool isUpvoted = _locallyUpvotedChirps.contains(chirp.id);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChirpDetailScreen(chirpId: chirp.id),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(title),
                        subtitle: Text('Posted by $authorLabel'),
                        // 5. REVISED LEADING WIDGET WITH INTERACTION
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_upward_outlined),
                              // Change color based on upvoted state
                              color: isUpvoted ? Theme.of(context).colorScheme.primary : null,
                              iconSize: 20,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                // TODO: Call Cloud Function to handle upvote
                                setState(() {
                                  // Toggle the upvote state for instant feedback
                                  if (isUpvoted) {
                                    _locallyUpvotedChirps.remove(chirp.id);
                                  } else {
                                    _locallyUpvotedChirps.add(chirp.id);
                                  }
                                });
                                debugPrint('Upvoting chirp: ${chirp.id}');
                              },
                            ),
                            Text(upvoteCount.toString()),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.comment_outlined, size: 20),
                            Text(replyCount.toString()),
                          ],
                        ),
                      ),
                    ),
                    if (mediaUrl != null && mediaUrl.isNotEmpty)
                      Column(
                        children: [
                          const Divider(height: 1),
                          Image.network(
                            mediaUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}