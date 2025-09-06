// lib/features/community/screens/flock_feed_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/widgets/unified_post_card.dart';
import 'package:intl/intl.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/community/widgets/dialogs/report_dialog.dart';
import 'package:cockatiel_companion/features/community/screens/feed_post_detail_screen.dart';

class FlockFeedScreen extends StatefulWidget {
  const FlockFeedScreen({super.key});

  @override
  State<FlockFeedScreen> createState() => _FlockFeedScreenState();
}

class _FlockFeedScreenState extends State<FlockFeedScreen> {
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat.yMMMd().add_jm().format(timestamp.toDate());
  }

  Future<void> _toggleLike(String postId) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('toggleFeedPostLike');
      await callable.call({'postId': postId});
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppStrings.genericError)),
        );
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ScreenTitles.deleteFeedPost),
        content: const Text(AppStrings.confirmDeleteFeedPost),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text(ButtonLabels.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(ButtonLabels.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('deleteFeedPost');
        await callable.call({'postId': postId});
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text(AppStrings.feedPostDeleted)));
      } on FirebaseFunctionsException catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(e.message ?? AppStrings.deleteFeedPostError)),
        );
      }
    }
  }

  void _showReportDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        title: ScreenTitles.reportFeedPost,
        onSubmit: (reason) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          try {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('reportContent');
            await callable.call({
              'contentType': 'feedPost',
              'contentId': postId,
              'reason': reason,
            });
            scaffoldMessenger.showSnackBar(const SnackBar(content: Text(AppStrings.reportReceived)));
          } on FirebaseFunctionsException catch (e) {
            scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.message ?? AppStrings.reportError)));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text(AppStrings.loginToViewFeed));

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
          return const Center(child: Text(AppStrings.somethingWentWrong));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                AppStrings.flockFeedEmpty,
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
            
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('community_feed_posts').doc(post.id)
                  .collection('likes').doc(currentUser.uid)
                  .snapshots(),
              builder: (context, likeSnapshot) {
                final bool isLiked = likeSnapshot.hasData && likeSnapshot.data!.exists;

                return UnifiedPostCard(
                  postType: PostType.feed,
                  authorId: data['authorId'] ?? '', // FIX: Add the required authorId
                  authorLabel: data['authorLabel'] ?? AppStrings.anonymous,
                  timestamp: _formatTimestamp(data['createdAt']),
                  body: data['body'],
                  mediaUrl: data['mediaUrl'],
                  actionCount1: data['likeCount'] ?? 0,
                  actionCount2: data['commentCount'] ?? 0,
                  isAction1Active: isLiked,
                  isAuthor: isAuthor,
                  onCardTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FeedPostDetailScreen(postId: post.id),
                      ),
                    );
                  },
                  onAction1Tap: () => _toggleLike(post.id),
                  onAction2Tap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FeedPostDetailScreen(postId: post.id),
                      ),
                    );
                  },
                  onMenuTap: () {
                    if (isAuthor) {
                      _deletePost(post.id);
                    } else {
                      _showReportDialog(post.id);
                    }
                  },
                );
              }
            );
          },
        );
      },
    );
  }
}