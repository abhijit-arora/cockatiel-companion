// lib/features/community/widgets/flock_feed_card.dart
import 'package:flutter/material.dart';

class FlockFeedCard extends StatelessWidget {
  // We will pass the real data in a later step.
  // For now, we use placeholders.
  const FlockFeedCard({super.key});

  @override
  Widget build(BuildContext context) {    
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. USER HEADER ---
          ListTile(
            leading: const CircleAvatar(
              // Placeholder for user profile picture
              child: Icon(Icons.person),
            ),
            title: const Text('KaKa Birdie of SpiceBox'), // Placeholder
            subtitle: const Text('2 hours ago'), // Placeholder
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Add Delete/Report functionality
              },
            ),
          ),

          // --- 2. MEDIA CONTENT (IMAGE/VIDEO) ---
          // Using a placeholder image for now.
          Image.network(
            'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/600/400',
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // --- 3. ACTION BAR (LIKE, COMMENT) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {
                        // TODO: Implement Like functionality
                      },
                    ),
                    const Text('0'), // Placeholder for like count
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () {
                        // TODO: Navigate to comments
                      },
                    ),
                    const Text('0'), // Placeholder for comment count
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    // TODO: Implement Save/Bookmark functionality
                  },
                ),
              ],
            ),
          ),

          // --- 4. POST CAPTION ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Just enjoying the beautiful day! #cockatiel #birdlife', // Placeholder
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}