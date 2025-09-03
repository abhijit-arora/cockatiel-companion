// lib/features/community/screens/flock_feed_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW IMPORT
import 'package:firebase_auth/firebase_auth.dart'; // NEW IMPORT
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/widgets/unified_post_card.dart';
import 'package:intl/intl.dart'; // NEW IMPORT for date formatting

class FlockFeedScreen extends StatelessWidget {
  const FlockFeedScreen({super.key});

  // NEW: Helper to format timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat.yMMMd().add_jm().format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text('Please log in to view the feed.')); // Safety check

    // The Scaffold and FAB are handled by the parent CommunityScreen.
    // This widget is now a live stream of data.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('community_feed_posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
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
                'The Flock Feed is quiet... Be the first to share something!',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final data = post.data() as Map<String, dynamic>;
            final bool isAuthor = currentUser.uid == data['authorId'];
            
            // TODO: In the next feature, we will wrap this in another StreamBuilder
            // to get the live "like" status for the action button.
            const bool isLiked = false; 

            return UnifiedPostCard(
              postType: PostType.feed,
              authorLabel: data['authorLabel'] ?? 'Anonymous',
              timestamp: _formatTimestamp(data['createdAt']),
              body: data['body'],
              mediaUrl: data['mediaUrl'],
              actionCount1: data['likeCount'] ?? 0,
              actionCount2: data['commentCount'] ?? 0,
              isAction1Active: isLiked,
              isAuthor: isAuthor,
              onCardTap: () {
                // TODO: Navigate to a Feed Post Detail screen
              },
              onAction1Tap: () {
                // TODO: Implement "Like" functionality
              },
              onMenuTap: () {
                // TODO: Implement Delete/Report for feed posts
              },
            );
          },
        );
      },
    );
  }
}