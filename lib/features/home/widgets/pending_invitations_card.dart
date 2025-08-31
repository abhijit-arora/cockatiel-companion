// lib/features/home/widgets/pending_invitations_card.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

class PendingInvitationsCard extends StatelessWidget {
  const PendingInvitationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('invitations')
          .where('inviteeEmail', isEqualTo: userEmail)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final invites = snapshot.data!.docs;
        
        return Column(
          children: invites.map((invite) => 
            _InvitationTile(invite: invite)
          ).toList(),
        );
      },
    );
  }
}

class _InvitationTile extends StatefulWidget {
  final DocumentSnapshot invite;
  const _InvitationTile({required this.invite});

  @override
  State<_InvitationTile> createState() => _InvitationTileState();
}

class _InvitationTileState extends State<_InvitationTile> {
  bool _isLoading = false;

  Future<void> _acceptInvite() async {
    setState(() { _isLoading = true; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.mustBeLoggedInToAccept)),
        );
      }
      setState(() { _isLoading = false; });
      return;
    }

    try {
      final app = Firebase.app();
      final functions = FirebaseFunctions.instanceFor(app: app, region: 'us-central1');
      final callable = functions.httpsCallable('acceptInvitation');

      final result = await callable.call({'invitationId': widget.invite.id});

      final data = (result.data is Map) ? Map<String, dynamic>.from(result.data as Map) : <String, dynamic>{};
      final message = (data['message'] as String?) ?? AppStrings.defaultSuccessMessage;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.errorPrefix} ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.invite.data() as Map<String, dynamic>;
    final String label = data['label'] ?? AppStrings.defaultCaregiverLabel;
    
    // Construct the invitation text from constants
    final String invitationText = '${AppStrings.invitationMessagePart1}$label${AppStrings.invitationMessagePart2}';

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              invitationText,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () { /* TODO: Decline logic */ },
                    child: const Text(ButtonLabels.decline),
                  ),
                  ElevatedButton(
                    onPressed: _acceptInvite,
                    child: const Text(ButtonLabels.acceptInvite),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}