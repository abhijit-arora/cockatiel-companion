// lib/features/community/screens/chirp_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/user/services/user_service.dart';
import 'package:cockatiel_companion/features/community/widgets/dialogs/report_dialog.dart';

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
    if (_replyController.text.trim().isEmpty) return;
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
          'latestActivityAt': FieldValue.serverTimestamp(),
        });
      });
      _replyController.clear();
    } catch (e) {
      debugPrint('Error posting reply: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.saveError} ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isReplying = false);
    }
  }

  Future<void> _toggleHelpful(String replyId) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('toggleReplyHelpful');
      await callable.call({'chirpId': widget.chirpId, 'replyId': replyId});
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Error toggling helpful: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppStrings.genericError)),
        );
      }

    }
  }

  Future<void> _showReportDialog(String replyId, String replyPath) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await showDialog(
      context: context,
      builder: (context) => ReportDialog(
        title: ScreenTitles.reportReply,
        onSubmit: (reason) async {
          try {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('reportContent');
            await callable.call({
              'contentType': 'reply',
              'contentId': replyPath,
              'reason': reason,
            });
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text(AppStrings.reportReceived)),
            );
          } on FirebaseFunctionsException catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(e.message ?? AppStrings.reportError)),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteReply(String replyId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ScreenTitles.confirmDeletion),
        content: const Text(AppStrings.confirmDeleteReply),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(ButtonLabels.cancel),
          ),
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
        final chirpRef = FirebaseFirestore.instance.collection('community_chirps').doc(widget.chirpId);
        final replyRef = chirpRef.collection('replies').doc(replyId);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.delete(replyRef);
          transaction.update(chirpRef, {'replyCount': FieldValue.increment(-1)});
        });
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text(AppStrings.deleteReplyError)),
          );
        }
      }
    }
  }

  Future<void> _markAsBestAnswer(String replyId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('markAsBestAnswer');
      await callable.call({
        'chirpId': widget.chirpId,
        'replyId': replyId,
      });
    } on FirebaseFunctionsException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.message ?? AppStrings.genericError)),
      );
    }
  }

  Widget _buildReplyCard(DocumentSnapshot reply, Map<String, dynamic> data, bool isChirpAuthor, bool isBest) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final int helpfulCount = data['helpfulCount'] ?? 0;
    final String authorId = data['authorId'] ?? '';
    final bool isReplyAuthor = currentUser?.uid == authorId;
    
    return Card(
      color: isReplyAuthor 
          ? Theme.of(context).colorScheme.primaryContainer.withAlpha(77) 
          : null,
      shape: isBest 
          ? RoundedRectangleBorder(
              side: BorderSide(color: Colors.green.shade600, width: 2),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBest)
              Chip(
                label: const Text(Labels.bestAnswer),
                backgroundColor: Colors.green.shade100,
                avatar: Icon(Icons.check_circle, color: Colors.green.shade800),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            Padding(
              padding: EdgeInsets.only(top: isBest ? 8.0 : 0),
              child: Text(data['body'] ?? ''),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            isReplyAuthor ? Labels.byYou : '${Labels.by} ${data['authorLabel'] ?? AppStrings.anonymous}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isReplyAuthor ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isReplyAuthor)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_chirps').doc(widget.chirpId)
                    .collection('replies').doc(reply.id)
                    .collection('helpfulMarkers').doc(currentUser?.uid)
                    .snapshots(),
                builder: (context, markerSnapshot) {
                  final bool isMarked = markerSnapshot.hasData && markerSnapshot.data!.exists;
                  return TextButton.icon(
                    icon: Icon(isMarked ? Icons.thumb_up : Icons.thumb_up_outlined, size: 16),
                    label: Text(helpfulCount.toString()),
                    style: TextButton.styleFrom(
                      foregroundColor: isMarked ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    onPressed: () => _toggleHelpful(reply.id),
                  );
                },
              ),
            if (isReplyAuthor)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(helpfulCount.toString()),
                ],
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20.0),
              onSelected: (value) {
                if (value == 'report') {
                  _showReportDialog(reply.id, reply.reference.path);
                } else if (value == 'delete') {
                  _deleteReply(reply.id);
                } else if (value == 'mark_best') {
                  _markAsBestAnswer(reply.id);
                }
              },
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> items = [];
                if (isReplyAuthor) {
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
                  if (isChirpAuthor && !isBest) {
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'mark_best',
                        child: ListTile(
                          leading: Icon(Icons.check_circle_outline, color: Colors.green),
                          title: Text(Labels.markAsBestAnswer),
                        ),
                      ),
                    );
                  }
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
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text(ScreenTitles.postDetail)),
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
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('community_chirps').doc(widget.chirpId).snapshots(),
                  builder: (context, chirpSnapshot) {
                    if (!chirpSnapshot.hasData) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    final chirpData = chirpSnapshot.data!.data() as Map<String, dynamic>;
                    final bestAnswerData = chirpData['bestAnswer'] as Map<String, dynamic>?;
                    final bestAnswerId = bestAnswerData?['replyId'] as String?;
                    final isChirpAuthor = currentUser?.uid == chirpData['authorId'];
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('community_chirps').doc(widget.chirpId)
                          .collection('replies').orderBy('createdAt').snapshots(),
                      builder: (context, replySnapshot) {
                        if (replySnapshot.connectionState == ConnectionState.waiting) {
                          return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                        }
                        if (!replySnapshot.hasData || replySnapshot.data!.docs.isEmpty) {
                          return const SliverToBoxAdapter(child: Center(child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(AppStrings.beFirstToReply),
                          )));
                        }
                        final allReplies = replySnapshot.data!.docs;
                        final bestAnswerReply = allReplies.where((doc) => doc.id == bestAnswerId).toList();
                        final otherReplies = allReplies.where((doc) => doc.id != bestAnswerId).toList();
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == 0 && bestAnswerReply.isNotEmpty) {
                                final reply = bestAnswerReply[0];
                                final data = reply.data() as Map<String, dynamic>;
                                return _buildReplyCard(reply, data, isChirpAuthor, true);
                              }
                              final replyIndex = bestAnswerReply.isNotEmpty ? index - 1 : index;
                              if (replyIndex < 0 || replyIndex >= otherReplies.length) return null;
                              final reply = otherReplies[replyIndex];
                              final data = reply.data() as Map<String, dynamic>;
                              return _buildReplyCard(reply, data, isChirpAuthor, false);
                            },
                            childCount: (bestAnswerReply.isNotEmpty ? 1 : 0) + otherReplies.length,
                          ),
                        );
                      },
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