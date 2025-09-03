// lib/features/community/widgets/chirp_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/screens/chirp_detail_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/community/widgets/dialogs/report_dialog.dart';
// --- NEW IMPORT ---
import 'package:cockatiel_companion/features/community/widgets/unified_post_card.dart';
import 'package:intl/intl.dart'; // For date formatting

class ChirpList extends StatefulWidget {
  final String category;
  final String sortBy;
  const ChirpList({super.key, required this.category, required this.sortBy});

  @override
  State<ChirpList> createState() => _ChirpListState();
}

class _ChirpListState extends State<ChirpList> {
  Future<void> _toggleFollow(String chirpId) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('toggleChirpFollow');
      await callable.call({'chirpId': chirpId});
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Error toggling follow: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppStrings.genericError)),
        );
      }
    }
  }

  Future<void> _showReportDialog(String chirpId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await showDialog(
      context: context,
      builder: (context) => ReportDialog(
        title: ScreenTitles.reportPost,
        onSubmit: (reason) async {
          try {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('reportContent');
            await callable.call({
              'contentType': 'chirp',
              'contentId': chirpId,
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
  
  Future<void> _deleteChirp(String chirpId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ScreenTitles.deleteQaPost),
        content: const Text(AppStrings.confirmDeleteQaPost),
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
        await FirebaseFirestore.instance.collection('community_chirps').doc(chirpId).delete();
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text(AppStrings.deleteQaPostError)),
          );
        }
      }
    }
  }

  // --- NEW: Helper to format timestamp for the UI ---
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat.yMMMd().add_jm().format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text(AppStrings.loginToViewCommunity));

    Query query = FirebaseFirestore.instance.collection('community_chirps');

    if (widget.sortBy == DropdownOptions.chirpSortOptions[0]) { // 'Latest Activity'
      query = query.orderBy('latestActivityAt', descending: true).orderBy('createdAt', descending: true);
    } else if (widget.sortBy == DropdownOptions.chirpSortOptions[1]) { // 'Most Follows'
      query = query.orderBy('followerCount', descending: true);
    } else if (widget.sortBy == DropdownOptions.chirpSortOptions[2]) { // 'Most Replies'
      query = query.orderBy('replyCount', descending: true);
    }
    
    final String allPostsCategory = DropdownOptions.communityCategoriesWithAll[0];
    if (widget.category != allPostsCategory) {
      query = query.where('category', isEqualTo: widget.category);
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
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
                  AppStrings.noPostsInCategory,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
    
          final chirps = snapshot.data!.docs;
    
          return ListView.builder(
            itemCount: chirps.length,
            itemBuilder: (context, index) {
              final chirp = chirps[index];
              final data = chirp.data() as Map<String, dynamic>;
    
              final bool isAuthor = currentUser.uid == data['authorId'];

              // --- A separate StreamBuilder to get the follow state for the action button ---
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_chirps').doc(chirp.id)
                    .collection('followers').doc(currentUser.uid)
                    .snapshots(),
                builder: (context, followSnapshot) {
                  final bool isFollowed = followSnapshot.hasData && followSnapshot.data!.exists;

                  // --- RENDER THE NEW UNIFIED WIDGET ---
                  return UnifiedPostCard(
                    postType: PostType.qa,
                    authorLabel: data['authorLabel'] ?? AppStrings.anonymous,
                    timestamp: _formatTimestamp(data['createdAt']),
                    title: data['title'] ?? AppStrings.noTitle,
                    mediaUrl: data['mediaUrl'],
                    actionCount1: data['followerCount'] ?? 0,
                    actionCount2: data['replyCount'] ?? 0,
                    isAction1Active: isFollowed,
                    isAuthor: isAuthor,
                    onCardTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChirpDetailScreen(chirpId: chirp.id),
                        ),
                      );
                    },
                    onAction1Tap: () => _toggleFollow(chirp.id),
                    onMenuTap: () {
                      if (isAuthor) {
                        _deleteChirp(chirp.id);
                      } else {
                        _showReportDialog(chirp.id);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}