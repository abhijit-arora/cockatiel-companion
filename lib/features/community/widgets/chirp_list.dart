// lib/features/community/widgets/chirp_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/community/screens/chirp_detail_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cockatiel_companion/core/constants.dart';

class ChirpList extends StatefulWidget {
  final String category;
  const ChirpList({super.key, required this.category});

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text(AppStrings.loginToViewCommunity));

    Query query = FirebaseFirestore.instance
        .collection('community_chirps')
        .orderBy('createdAt', descending: true);
    
    final String allPostsCategory = DropdownOptions.communityCategoriesWithAll[0];
    if (widget.category != allPostsCategory) {
      query = query.where('category', isEqualTo: widget.category);
    }

    return StreamBuilder<QuerySnapshot>(
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

            final String title = data['title'] ?? AppStrings.noTitle;
            final String authorLabel = data['authorLabel'] ?? AppStrings.anonymous;
            final int replyCount = data['replyCount'] ?? 0;
            final int followerCount = data['followerCount'] ?? 0;
            final String? mediaUrl = data['mediaUrl'];
            // --- NEW: Check if the current user is the author ---
            final bool isAuthor = currentUser.uid == data['authorId'];

            return Card(
              // --- NEW: Conditional highlighting ---
              color: isAuthor ? Theme.of(context).colorScheme.primaryContainer.withAlpha(77) : null, // 0.3 * 255 = 76.5, rounded to 77
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChirpDetailScreen(chirpId: chirp.id),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          // --- NEW: Conditional author text ---
                          Text(
                            isAuthor ? Labels.postedByYou : '${Labels.postedBy} $authorLabel',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              // Optional: make "You" bold to stand out
                              fontWeight: isAuthor ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (mediaUrl != null && mediaUrl.isNotEmpty)
                      Image.network(
                        mediaUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('community_chirps')
                                .doc(chirp.id)
                                .collection('followers')
                                .doc(currentUser.uid)
                                .snapshots(),
                            builder: (context, followSnapshot) {
                              final bool isFollowed = followSnapshot.hasData && followSnapshot.data!.exists;
                              return ElevatedButton.icon(
                                icon: Icon(
                                  isFollowed ? Icons.check : Icons.add,
                                  size: 16,
                                ),
                                label: Text(isFollowed ? '${AppStrings.followingPost} ($followerCount)' : '${AppStrings.followPost} ($followerCount)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowed 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).colorScheme.surface,
                                  foregroundColor: isFollowed 
                                      ? Theme.of(context).colorScheme.onPrimary 
                                      : Theme.of(context).colorScheme.primary,
                                  side: isFollowed ? BorderSide.none : BorderSide(color: Theme.of(context).colorScheme.outline),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                ),
                                onPressed: () => _toggleFollow(chirp.id),
                              );
                            },
                          ),
                          Row(
                            children: [
                              const Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(replyCount.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}