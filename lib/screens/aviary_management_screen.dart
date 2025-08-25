import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/widgets/aviary_dialogs/invite_caregiver_dialog.dart';

class AviaryManagementScreen extends StatefulWidget {
  const AviaryManagementScreen({super.key});

  @override
  State<AviaryManagementScreen> createState() => _AviaryManagementScreenState();
}

class _AviaryManagementScreenState extends State<AviaryManagementScreen> {
  String? _aviaryId;

  @override
  void initState() {
    super.initState();
    _determineAviaryId();
  }

  Future<void> _determineAviaryId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (mounted) {
      if (userDoc.exists && userDoc.data()!.containsKey('partOfAviary')) {
        setState(() => _aviaryId = userDoc.data()!['partOfAviary']);
      } else {
        setState(() => _aviaryId = user.uid);
      }
    }
  }

  Future<void> _sendInvite({required String email, required String label}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('invitations').add({
        'aviaryOwnerId': _aviaryId, // Use the determined aviaryId
        'inviteeEmail': email.toLowerCase(),
        'label': label,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation sent to $email!')),
        );
      }
    } catch (e) {
      print('Error sending invitation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not send invitation.')),
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

  Widget _buildCaregiverList(String aviaryId) {
    return StreamBuilder<QuerySnapshot>(
      // --- REVISED QUERY ---
      stream: FirebaseFirestore.instance.collection('aviaries').doc(aviaryId).collection('caregivers').snapshots(),
      builder: (context, caregiverSnapshot) {
        if (!caregiverSnapshot.hasData) return const SizedBox.shrink();
        final caregivers = caregiverSnapshot.data!.docs;
        return Column(
          children: caregivers.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(data['label'] ?? 'Caregiver'),
                subtitle: Text(data['email']),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPendingInvitesList(String aviaryId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('invitations')
          .where('aviaryOwnerId', isEqualTo: aviaryId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
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
                    FirebaseFirestore.instance.collection('invitations').doc(invite.id).delete();
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Aviary'),
      ),
      body: _aviaryId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              // --- REVISED QUERY ---
              stream: FirebaseFirestore.instance.collection('aviaries').doc(_aviaryId).snapshots(),
              builder: (context, aviarySnapshot) {
                if (!aviarySnapshot.hasData || !aviarySnapshot.data!.exists) {
                  return const Center(child: Text("Aviary not found."));
                }
                
                final aviaryData = aviarySnapshot.data!.data() as Map<String, dynamic>;
                final guardianEmail = aviaryData['guardianEmail'] ?? 'Guardian';
                
                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    _buildSectionHeader(context, 'Caregivers'),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.amber),
                        title: Text(guardianEmail),
                        subtitle: const Text('Guardian'),
                      ),
                    ),
                    _buildCaregiverList(_aviaryId!),
                    _buildPendingInvitesList(_aviaryId!),
                    
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Invite a Caregiver'),
                        onPressed: _showInviteDialog,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}