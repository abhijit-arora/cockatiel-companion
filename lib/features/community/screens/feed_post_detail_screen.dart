// lib/features/community/screens/feed_post_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/community/widgets/unified_post_card.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/features/community/widgets/dialogs/report_dialog.dart';

class FeedPostDetailScreen extends StatefulWidget {
  final String postId;
  const FeedPostDetailScreen({super.key, required this.postId});
  @override
  State<FeedPostDetailScreen> createState() => _FeedPostDetailScreenState();
}

class _FeedPostDetailScreenState extends State<FeedPostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isPostingComment = false;

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isPostingComment = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('addFeedComment');
      await callable.call({
        'postId': widget.postId,
        'body': _commentController.text.trim(),
      });
      _commentController.clear();
    } on FirebaseFunctionsException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.message ?? AppStrings.saveError)),
      );
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
    }
  }

  // --- NEW: LOGIC FOR INTERACTIONS, MOVED FROM THE LIST SCREEN ---
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
    final navigator = Navigator.of(context);
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
        navigator.pop(); // Go back to the feed screen after deletion
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text(AppStrings.feedPostDeleted)));
      } on FirebaseFunctionsException catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(e.message ?? AppStrings.deleteFeedPostError)),
        );
      }
    }
  }

  Future<void> _toggleCommentLike(String commentPath) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('toggleCommentLike');
      await callable.call({'commentId': commentPath});
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppStrings.genericError)),
        );
      }
    }
  }
  
  void _showReportCommentDialog(String commentPath) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        title: ScreenTitles.reportComment,
        onSubmit: (reason) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          try {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('reportContent');
            await callable.call({
              'contentType': 'comment', // A new type for our generic function
              'contentId': commentPath,
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

  Future<void> _deleteComment(String commentId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment?'),
        content: const Text('Are you sure you want to permanently delete this comment?'),
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
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('deleteFeedComment');
        await callable.call({'postId': widget.postId, 'commentId': commentId});
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Comment deleted.')));
      } on FirebaseFunctionsException catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(e.message ?? 'Could not delete comment.')),
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat.yMMMd().add_jm().format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method up to the SliverList is unchanged) ...
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Scaffold(body: Center(child: Text(AppStrings.loginToViewFeed)));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.feedPostAndComments),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('community_feed_posts').doc(widget.postId).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
                      if (!snapshot.data!.exists) return const Center(child: Text(AppStrings.postNotFound));
                      
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final isAuthor = currentUser.uid == data['authorId'];
                      
                      return StreamBuilder<DocumentSnapshot>(
                        stream: snapshot.data!.reference.collection('likes').doc(currentUser.uid).snapshots(),
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
                            onCardTap: () {},
                            onAction1Tap: () => _toggleLike(widget.postId),
                            onMenuTap: () {
                              if (isAuthor) {
                                _deletePost(widget.postId);
                              } else {
                                _showReportDialog(widget.postId);
                              }
                            },
                          );
                        }
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(AppStrings.comments, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('community_feed_posts').doc(widget.postId)
                      .collection('comments').orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    if (snapshot.data!.docs.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text(AppStrings.beFirstToComment))));
                    }

                    final comments = snapshot.data!.docs;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final comment = comments[index];
                          final data = comment.data() as Map<String, dynamic>;
                          final isCommentAuthor = currentUser.uid == data['authorId'];
                          final timestamp = _formatTimestamp(data['createdAt']);
                          final authorId = data['authorId'] ?? '';
                          
                          return Card(
                            color: isCommentAuthor ? Theme.of(context).colorScheme.primaryContainer.withAlpha(77) : null,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance.collection('aviaries').doc(authorId).snapshots(),
                                builder: (context, snapshot) {
                                  String? avatarSvg;
                                  if (snapshot.hasData && snapshot.data!.exists) {
                                    final data = snapshot.data!.data() as Map<String, dynamic>;
                                    avatarSvg = data['avatarSvg'];
                                  }
                                  return CircleAvatar(
                                    child: avatarSvg != null
                                        ? SvgPicture.string(avatarSvg)
                                        : const Icon(Icons.person),
                                  );
                                },
                              ),
                              title: Text(data['body'] ?? ''),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isCommentAuthor ? Labels.byYou : (data['authorLabel'] ?? AppStrings.anonymous),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      timestamp,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // --- LIKE BUTTON ---
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: comment.reference.collection('likes').doc(currentUser.uid).snapshots(),
                                    builder: (context, likeSnapshot) {
                                      final bool isLiked = likeSnapshot.hasData && likeSnapshot.data!.exists;
                                      return TextButton.icon(
                                        icon: Icon(
                                          isLiked ? Icons.favorite : Icons.favorite_border,
                                          size: 20,
                                          color: isLiked ? Colors.red : Colors.grey,
                                        ),
                                        label: Text((data['likeCount'] ?? 0).toString()),
                                        style: TextButton.styleFrom(foregroundColor: Colors.grey),
                                        onPressed: () {
                                           _toggleCommentLike(comment.reference.path);
                                        },
                                      );
                                    }
                                  ),
                                  // --- DELETE / REPORT MENU ---
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20.0),
                                    onSelected: (value) {
                                      if (value == 'report') {
                                        _showReportCommentDialog(comment.reference.path);
                                      } else if (value == 'delete') {
                                        _deleteComment(comment.id);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      List<PopupMenuEntry<String>> items = [];
                                      if (isCommentAuthor) {
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
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: comments.length,
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
          // ... (Reply input field is unchanged)
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: AppStrings.addCommentHint,
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isPostingComment ? null : _postComment,
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