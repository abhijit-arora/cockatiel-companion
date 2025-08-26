import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:cockatiel_companion/widgets/aviary_dialogs/invite_caregiver_dialog.dart';
import 'package:cockatiel_companion/widgets/aviary_dialogs/add_edit_nest_dialog.dart';

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
    if (!mounted) return;
    if (userDoc.exists && userDoc.data()!.containsKey('partOfAviary')) {
      setState(() => _aviaryId = userDoc.data()!['partOfAviary'] as String?);
    } else {
      setState(() => _aviaryId = user.uid);
    }
  }

  // --- HELPERS ---

  Future<void> _sendInvite({required String email, required String label}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _aviaryId == null) return;
    try {
      await FirebaseFirestore.instance.collection('invitations').add({
        'aviaryOwnerId': _aviaryId,
        'inviteeEmail': email.toLowerCase(),
        'label': label,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to $email!')),
      );
    } catch (e) {
      debugPrint('Error sending invitation: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not send invitation.')),
      );
    }
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => InviteCaregiverDialog(onInvite: _sendInvite),
    );
  }

  Widget _header(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      );

  Future<void> _addNest(String name) async {
    if (_aviaryId == null) return;
    await FirebaseFirestore.instance
        .collection('aviaries')
        .doc(_aviaryId)
        .collection('nests')
        .add({'name': name, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> _updateNest(String nestId, String newName) async {
    if (_aviaryId == null) return;
    await FirebaseFirestore.instance
        .collection('aviaries')
        .doc(_aviaryId)
        .collection('nests')
        .doc(nestId)
        .update({'name': newName});
  }

  void _showEditNestDialog(String nestId, String currentName) async { // <-- Make async
    await showDialog( // <-- await the result
      context: context,
      builder: (context) => AddEditNestDialog(
        initialName: currentName,
        onSave: (newName) => _updateNest(nestId, newName),
      ),
    );
    // After the dialog is closed, force a rebuild.
    setState(() {});
  }

  void _showAddNestDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddEditNestDialog(onSave: _addNest),
    );
    setState(() {});
  }

  Future<void> _deleteNest(String nestId, int birdCount) async {
    if (_aviaryId == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final nestsSnapshot = await FirebaseFirestore.instance
        .collection('aviaries')
        .doc(_aviaryId)
        .collection('nests')
        .get();

    if (nestsSnapshot.docs.length <= 1) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('You cannot delete your last nest.')),
      );
      return;
    }

    if (birdCount > 0) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('You cannot delete a nest that has birds in it.')),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this nest?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('aviaries')
          .doc(_aviaryId)
          .collection('nests')
          .doc(nestId)
          .delete();
    }
  }

  Widget _caregiverList(String aviaryId) {
    return StreamBuilder<QuerySnapshot>(
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
                subtitle: Text(data['email'] ?? doc.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _pendingInvitesList(String aviaryId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('invitations')
          .where('aviaryOwnerId', isEqualTo: aviaryId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink(); // caregivers won't have access
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        final invites = snapshot.data!.docs;
        return Column(
          children: invites.map((invite) {
            final data = invite.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(data['inviteeEmail']),
                subtitle: const Text('Invitation Pending...'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: (){
                    FirebaseFirestore.instance.collection('invitations').doc(invite.id).delete();
                    setState(() {});
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
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Your Aviary')),
      body: _aviaryId == null
          ? const Center(child: CircularProgressIndicator())
          : Builder(builder: (context) {
              final isGuardian = uid == _aviaryId!;
              final birdsStream = FirebaseFirestore.instance
                  .collection('birds')
                  .where('ownerId', isEqualTo: _aviaryId)
                  .where('viewers', arrayContains: uid)
                  .snapshots();

              final aviaryDocStream =
                  FirebaseFirestore.instance.collection('aviaries').doc(_aviaryId).snapshots();

              final nestsStream = FirebaseFirestore.instance
                  .collection('aviaries')
                  .doc(_aviaryId)
                  .collection('nests')
                  .snapshots();

              return StreamBuilder<List<dynamic>>(
                stream: StreamZip([aviaryDocStream, nestsStream, birdsStream]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    debugPrint('AviaryManagement error: ${snapshot.error}');
                    return const Center(child: Text('Error loading data.'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No data found.'));
                  }

                  final aviaryDoc = snapshot.data![0] as DocumentSnapshot;
                  if (!aviaryDoc.exists) {
                    return const Center(child: Text('Aviary not found.'));
                  }

                  final nests = (snapshot.data![1] as QuerySnapshot).docs;
                  final birds = (snapshot.data![2] as QuerySnapshot).docs;
                  final aviaryData = aviaryDoc.data()! as Map<String, dynamic>;
                  final guardianEmail = aviaryData['guardianEmail'] ?? 'Guardian';

                  return ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      _header(context, 'Your Nests (Cages)'),
                      if (isGuardian)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add a New Nest'),
                            onPressed: _showAddNestDialog,
                          ),
                        ),
                      if (nests.isEmpty)
                        const Card(child: ListTile(title: Text('No nests created yet.')))
                      else
                        ...nests.map((nestDoc) {
                          final nestData = nestDoc.data() as Map<String, dynamic>;
                          final birdCount = birds.where((bird) => bird['nestId'] == nestDoc.id).length;
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.home_work_outlined),
                              title: Text(nestData['name'] ?? 'Unnamed Nest'),
                              subtitle: Text('$birdCount bird(s)'),
                              trailing: isGuardian
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_note),
                                          onPressed: () => _showEditNestDialog(nestDoc.id, nestData['name']),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () async { // <-- Make the handler async
                                            await _deleteNest(nestDoc.id, birdCount); // <-- Await the result
                                            setState(() {}); // <-- Force the rebuild
                                          },
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        }),
                      const SizedBox(height: 24),
                      _header(context, 'Caregivers'),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.amber),
                          title: Text(guardianEmail),
                          subtitle: const Text('Guardian'),
                        ),
                      ),
                      _caregiverList(_aviaryId!),
                      if (isGuardian) _pendingInvitesList(_aviaryId!),
                      const SizedBox(height: 16),
                      if (isGuardian)
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
              );
            }),
    );
  }
}