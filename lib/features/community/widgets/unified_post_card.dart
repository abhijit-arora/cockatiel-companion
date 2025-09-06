// lib/features/community/widgets/unified_post_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:flutter_svg/svg.dart';

enum PostType { qa, feed }

class UnifiedPostCard extends StatelessWidget {
  final PostType postType;
  final String authorId;
  final String authorLabel;
  final String? authorAvatarSvg;
  final String timestamp;
  final String? title;
  final String? body;
  final String? mediaUrl;
  final int actionCount1;
  final int actionCount2;
  final bool isAction1Active;
  final bool isAuthor;
  final VoidCallback onCardTap;
  final VoidCallback onAction1Tap;
  final VoidCallback? onAction2Tap;
  final VoidCallback onMenuTap;

  const UnifiedPostCard({
    super.key,
    required this.postType,
    required this.authorId,
    required this.authorLabel,
    this.authorAvatarSvg,
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
    this.onAction2Tap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- Determine labels and icons based on PostType ---
    final String action1Label = postType == PostType.qa ? AppStrings.followPost : AppStrings.like;
    final String action1ActiveLabel = postType == PostType.qa ? AppStrings.followingPost : AppStrings.liked;
    final IconData action1Icon = postType == PostType.qa ? Icons.add : Icons.favorite_border;
    final IconData action1ActiveIcon = postType == PostType.qa ? Icons.check : Icons.favorite;
    final IconData action2Icon = postType == PostType.qa ? Icons.comment_outlined : Icons.chat_bubble_outline;

    return Card(
      color: isAuthor ? theme.colorScheme.primaryContainer.withAlpha(77) : null,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('aviaries').doc(authorId).snapshots(),
              builder: (context, snapshot) {
                String? avatarSvg;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  avatarSvg = data['avatarSvg'];
                }
                return CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: avatarSvg != null
                      ? SvgPicture.string(avatarSvg)
                      : const Icon(Icons.person),
                );
              },
            ),
            title: Text(
              isAuthor ? Labels.postedByYou : authorLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isAuthor ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(timestamp),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  onMenuTap();
                } else if (value == 'report') {
                  onMenuTap();
                }
              },
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> items = [];
                if (isAuthor) {
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text(ButtonLabels.delete),
                      ),
                    ),
                  );
                } else {
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'report',
                      child: ListTile(
                        leading: Icon(Icons.flag_outlined),
                        title: Text(ButtonLabels.report),
                      ),
                    ),
                  );
                }
                return items;
              },
            ),
          ),
          InkWell(
            onTap: onCardTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // --- REVISED: Conditional Action Button 1 ---
                    if (postType == PostType.feed && isAuthor)
                      // For authors on feed, show a static icon and text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.favorite, size: 20, color: Colors.grey.shade400),
                            const SizedBox(width: 8),
                            Text(actionCount1.toString(), style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    else
                      // For everyone else, show the interactive button
                      ElevatedButton.icon(
                        icon: Icon(isAction1Active ? action1ActiveIcon : action1Icon, size: 16),
                        label: Text(
                          // Conditionally add a space if the label is not empty
                          '${isAction1Active ? action1ActiveLabel : action1Label}${action1Label.isNotEmpty ? ' ' : ''}($actionCount1)',
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
                    InkWell(
                      onTap: onAction2Tap,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(action2Icon, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(actionCount2.toString()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () { /* TODO: Implement Bookmark */ },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}