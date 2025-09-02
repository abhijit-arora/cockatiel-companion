// lib/features/community/widgets/unified_post_card.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

// Enum to define the type of post, which controls the action buttons
enum PostType { qa, feed }

class UnifiedPostCard extends StatelessWidget {
  final PostType postType;
  final String authorLabel;
  final String timestamp;
  final String? title; // Optional: For Q&A posts
  final String? body;
  final String? mediaUrl;
  final int actionCount1; // Follower or Like count
  final int actionCount2; // Reply or Comment count
  final bool isAction1Active; // Is the user following or has liked?
  final bool isAuthor;
  final VoidCallback onCardTap;
  final VoidCallback onAction1Tap;
  final VoidCallback onMenuTap;

  const UnifiedPostCard({
    super.key,
    required this.postType,
    required this.authorLabel,
    required this.timestamp,
    this.title,
    this.body,
    this.mediaUrl,
    required this.actionCount1,
    required this.actionCount2,
    required this.isAction1Active,
    required this.isAuthor,
    required this.onCardTap,
    required this.onAction1Tap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- Determine labels based on PostType ---
    final String action1Label = postType == PostType.qa ? AppStrings.followPost : 'Like';
    final String action1ActiveLabel = postType == PostType.qa ? AppStrings.followingPost : 'Liked';
    final IconData action1Icon = postType == PostType.qa ? Icons.add : Icons.favorite_border;
    final IconData action1ActiveIcon = postType == PostType.qa ? Icons.check : Icons.favorite;
    final IconData action2Icon = postType == PostType.qa ? Icons.comment_outlined : Icons.chat_bubble_outline;

    return Card(
      color: isAuthor ? theme.colorScheme.primaryContainer.withAlpha(77) : null,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onCardTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. USER HEADER ---
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: const Icon(Icons.person),
              ),
              title: Text(
                isAuthor ? Labels.postedByYou : authorLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isAuthor ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(timestamp),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onMenuTap,
              ),
            ),

            // --- 2. TEXT CONTENT (TITLE & BODY) ---
            if (title != null && title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(title!, style: theme.textTheme.titleLarge),
              ),
            if (body != null && body!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(body!),
              ),
            
            // --- 3. MEDIA ---
            if (mediaUrl != null && mediaUrl!.isNotEmpty)
              Image.network(
                mediaUrl!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),

            // --- 4. ACTION BAR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Action Button 1 (Follow / Like)
                      ElevatedButton.icon(
                        icon: Icon(isAction1Active ? action1ActiveIcon : action1Icon, size: 16),
                        label: Text(
                          '${isAction1Active ? action1ActiveLabel : action1Label} ($actionCount1)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAction1Active ? theme.colorScheme.primary : theme.colorScheme.surface,
                          foregroundColor: isAction1Active ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                          side: isAction1Active ? BorderSide.none : BorderSide(color: theme.colorScheme.outline),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        onPressed: onAction1Tap,
                      ),
                      const SizedBox(width: 16),
                      // Action Button 2 (Reply / Comment)
                      Row(
                        children: [
                          Icon(action2Icon, size: 20, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(actionCount2.toString()),
                        ],
                      ),
                    ],
                  ),
                  // Bookmark Button
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () { /* TODO: Implement Bookmark */ },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}