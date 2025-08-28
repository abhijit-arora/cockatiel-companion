import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChirpList extends StatelessWidget {
  final String category;

  const ChirpList({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // 1. Build the base query to our new collection.
    Query query = FirebaseFirestore.instance
        .collection('community_chirps')
        .orderBy('createdAt', descending: true);

    // 2. If a specific category is selected (not 'All Chirps'), filter by it.
    if (category != 'All Chirps') {
      query = query.where('category', isEqualTo: category);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        // 3. Handle loading, error, and empty states.
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

        // 4. Build the list of Chirps.
        return ListView.builder(
          itemCount: chirps.length,
          itemBuilder: (context, index) {
            final chirp = chirps[index];
            final data = chirp.data() as Map<String, dynamic>;

            final String title = data['title'] ?? 'No Title';
            final String authorLabel = data['authorLabel'] ?? 'Anonymous';
            final int replyCount = data['replyCount'] ?? 0;
            final int upvoteCount = data['upvoteCount'] ?? 0;
            // TODO: We will add date formatting later for a cleaner look.
            final String timestamp = data['createdAt']?.toString() ?? 'No date';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(title),
                subtitle: Text('Posted by $authorLabel'),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_upward_outlined, size: 20),
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
                onTap: () {
                  // TODO: Navigate to the detailed Chirp view screen.
                },
              ),
            );
          },
        );
      },
    );
  }
}