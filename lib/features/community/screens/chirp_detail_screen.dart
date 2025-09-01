// lib/features/community/screens/chirp_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/user/services/user_service.dart';

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
      setState(() => _isReplying = false);
      return;
    }

    try {
      final chirpRef = FirebaseFirestore.instance.collection('community_chirps').doc(widget.chirpId);
      final authorLabel = await UserService.getAuthorLabelForCurrentUser();

      await chirpRef.collection('replies').add({
        'body': _replyController.text.trim(),
        'authorId': user.uid,
        'authorLabel': authorLabel,
        'createdAt': FieldValue.serverTimestamp(),
        'helpfulCount': 0,
      });

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

  Future<void> _toggleHelpful(String replyId) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('toggleReplyHelpful');
      await callable.call({
        'chirpId': widget.chirpId,
        'replyId': replyId,
      });
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Error toggling helpful: ${e.message}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.postDetail),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('community_chirps').doc(widget.chirpId).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator()));
                      }
                      if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text(AppStrings.postNotFound));
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final String title = data['title'] ?? AppStrings.noTitle;
                      final String body = data['body'] ?? '';
                      final String authorLabel = data['authorLabel'] ?? AppStrings.anonymous;
                      final String? mediaUrl = data['mediaUrl'];
                      final Timestamp? timestamp = data['createdAt'];
                      final bool isChirpAuthor = currentUser?.uid == data['authorId'];

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                              isChirpAuthor ? Labels.postedByYou : '${Labels.postedBy} $authorLabel',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: isChirpAuthor ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (timestamp != null)
                              Text(DateFormat.yMMMd().add_jm().format(timestamp.toDate()), style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 16),
                            
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
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
                              ),
                            
                            const Divider(height: 24),
                            Text(Labels.replies, style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('community_chirps')
                      .doc(widget.chirpId)
                      .collection('replies')
                      .orderBy('createdAt')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(AppStrings.beFirstToReply),
                      )));
                    }

                    final replies = snapshot.data!.docs;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final reply = replies[index];
                          final data = reply.data() as Map<String, dynamic>;
                          final int helpfulCount = data['helpfulCount'] ?? 0;
                          final String authorId = data['authorId'] ?? '';
                          final bool isReplyAuthor = currentUser?.uid == authorId;

                          return Card(
                            color: isReplyAuthor ? Theme.of(context).colorScheme.primaryContainer.withAlpha(77) : null,
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['body'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isReplyAuthor ? Labels.byYou : '${Labels.by} ${data['authorLabel'] ?? AppStrings.anonymous}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                           fontWeight: isReplyAuthor ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      if (!isReplyAuthor)
                                        Row(
                                          children: [
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('community_chirps')
                                                  .doc(widget.chirpId)
                                                  .collection('replies')
                                                  .doc(reply.id)
                                                  .collection('helpfulMarkers')
                                                  .doc(currentUser?.uid)
                                                  .snapshots(),
                                              builder: (context, markerSnapshot) {
                                                final bool isMarked = markerSnapshot.hasData && markerSnapshot.data!.exists;
                                                return ElevatedButton.icon(
                                                  icon: Icon(
                                                    isMarked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                                    size: 16,
                                                  ),
                                                  label: Text(Labels.helpful),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: isMarked 
                                                        ? Theme.of(context).colorScheme.primary 
                                                        : Theme.of(context).colorScheme.surface,
                                                    foregroundColor: isMarked 
                                                        ? Theme.of(context).colorScheme.onPrimary 
                                                        : Theme.of(context).colorScheme.primary,
                                                    side: isMarked ? BorderSide.none : BorderSide(color: Theme.of(context).colorScheme.outline),
                                                    elevation: 0,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                  ),
                                                  onPressed: () => _toggleHelpful(reply.id),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            Text(helpfulCount.toString()),
                                          ],
                                        ),
                                      if (isReplyAuthor)
                                        Row(
                                          children: [
                                            const Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(helpfulCount.toString()),
                                          ],
                                        )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: replies.length,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: AppStrings.addReplyHint,
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