import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cockatiel_companion/widgets/aviary_dialogs/invite_caregiver_dialog.dart';

class AviaryManagementScreen extends StatefulWidget {
  const AviaryManagementScreen({super.key});

  @override
  State<AviaryManagementScreen> createState() => _AviaryManagementScreenState();
}

class _AviaryManagementScreenState extends State<AviaryManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Aviary'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // --- NESTS SECTION ---
          _buildSectionHeader(context, 'Your Nests (Cages)'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.home_work_outlined),
              title: const Text('My First Nest'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to Nest detail/edit screen
              },
            ),
          ),
          // We will eventually show a list of Nests here
          
          const SizedBox(height: 24),

          // --- CAREGIVERS SECTION ---
          _buildSectionHeader(context, 'Caregivers'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('You (Guardian)'), // Display the current user
              onTap: () {
                // This could open the user's own profile in the future
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('invitations')
                .where('aviaryOwnerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink(); // Show nothing if no pending invites
              }
              final invites = snapshot.data!.docs;
              return Column(
                children: invites.map((invite) {
                  final data = invite.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.mail_outline, color: Colors.grey),
                      title: Text(data['inviteeEmail']),
                      subtitle: const Text('Invitation Pending...'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          // TODO: Implement delete/cancel invitation logic
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Invite a Caregiver'),
              onPressed: () {
                _showInviteDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to create styled section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Future<void> _sendInvite({required String email, required String label}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('invitations').add({
        'aviaryOwnerId': user.uid,
        'inviteeEmail': email.toLowerCase(), // Store emails consistently
        'label': label,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation sent to $email!')),
        );
      }
    } catch (e) {
      print('Error sending invitation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Could not send invitation.')),
        );
      }
    }
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => InviteCaregiverDialog(onInvite: _sendInvite),
    );
  }
}