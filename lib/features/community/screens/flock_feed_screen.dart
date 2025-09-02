// lib/features/community/screens/flock_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/widgets/unified_post_card.dart';

class FlockFeedScreen extends StatelessWidget {
  const FlockFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We are now using ListView.builder with our new UnifiedPostCard
    return ListView.builder(
      itemCount: 5, // Still using 5 placeholder cards
      itemBuilder: (context, index) {
        // --- Pass placeholder data to the new unified card ---
        return UnifiedPostCard(
          postType: PostType.feed, // CRITICAL: This tells the card to show "Like/Comment"
          authorLabel: 'KaKa Birdie of SpiceBox',
          timestamp: '2 hours ago',
          body: 'Just enjoying the beautiful day! #cockatiel #birdlife',
          mediaUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch + index}/600/400',
          actionCount1: 0, // Like count
          actionCount2: 0, // Comment count
          isAction1Active: false, // User has not liked this post
          isAuthor: false, // Assume not the author for placeholder
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
  }
}