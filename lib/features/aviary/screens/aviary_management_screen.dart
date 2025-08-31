// lib/features/aviary/screens/aviary_management_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:cockatiel_companion/features/aviary/screens/bulk_move_screen.dart';
import 'package:cockatiel_companion/features/aviary/widgets/aviary_dialogs/invite_caregiver_dialog.dart';
import 'package:cockatiel_companion/features/aviary/widgets/aviary_dialogs/add_edit_nest_dialog.dart';
import 'package:cockatiel_companion/core/constants.dart';

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
        setState(() => _aviaryId = userDoc.data()!['partOfAviary'] as String?);
      } else {
        setState(() => _aviaryId = user.uid);
      }
    }
  }

  void _showEditAviaryNameDialog(String currentName) async {
    final nameController = TextEditingController(text: currentName);
    // --- The BuildContext is used inside the builder, which is synchronous, so no capture needed here. ---
    await showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        String? errorText; 

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text(ScreenTitles.setPublicHouseholdName),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: AppStrings.householdNameExample,
                      errorText: errorText,
                      errorMaxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.householdNameUniquenessNotice,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(ButtonLabels.cancel),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    // --- Capture navigator inside the async callback ---
                    final navigator = Navigator.of(context);
                    dialogSetState(() {
                      isSaving = true;
                      errorText = null;
                    });

                    try {
                      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('setAviaryName');
                      await callable.call({'name': nameController.text});
                      // Use the captured navigator
                      if (mounted) navigator.pop();
                    } on FirebaseFunctionsException catch (e) {
                      dialogSetState(() {
                        errorText = e.message;
                      });
                    } finally {
                      dialogSetState(() {
                        isSaving = false;
                      });
                    }
                  },
                  child: isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text(ButtonLabels.save),
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {});
  }
  
  Future<void> _sendInvite({required String email, required String label}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _aviaryId == null) return;
    // --- Capture scaffoldMessenger before the async gap ---
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance.collection('invitations').add({
        'aviaryOwnerId': _aviaryId,
        'inviteeEmail': email.toLowerCase(),
        'label': label,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${AppStrings.invitationSent} $email!')),
      );
    } catch (e) {
      debugPrint('Error sending invitation: $e');
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.invitationError)),
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

  void _showEditNestDialog(String nestId, String currentName) async {
    await showDialog(
      context: context,
      builder: (context) => AddEditNestDialog(
        initialName: currentName,
        onSave: (newName) => _updateNest(nestId, newName),
      ),
    );
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
    // --- Capture scaffoldMessenger before the async gap ---
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final nestsSnapshot = await FirebaseFirestore.instance
      .collection('aviaries')
      .doc(_aviaryId)
      .collection('nests')
      .get();

    if (!mounted) return;

    if (nestsSnapshot.docs.length <= 1) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.cannotDeleteLastEnclosure)),
      );
      return;
    }

    if (birdCount > 0) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.cannotDeleteEnclosureWithPets)),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context, // Now it's safe to use the original context
      builder: (bContext) => AlertDialog(
        title: const Text(ScreenTitles.confirmDeletion),
        content: const Text(AppStrings.confirmEnclosureDeletion),
        actions: [
          TextButton(onPressed: () => Navigator.of(bContext).pop(false), child: const Text(ButtonLabels.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(bContext).pop(true),
            child: const Text(ButtonLabels.delete),
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

  Future<bool> _updateGuardianLabel(String newLabel) async {
    if (_aviaryId == null || newLabel.trim().isEmpty) return false;
    // --- Capture scaffoldMessenger before the async gap ---
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance
          .collection('aviaries')
          .doc(_aviaryId)
          .update({'guardianLabel': newLabel.trim()});
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.primaryOwnerLabelUpdated)),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error updating guardian label: $e');
      return false;
    }
  }

  void _showEditGuardianLabelDialog(String currentLabel) async {
    final labelController = TextEditingController(text: currentLabel);
    await showDialog<bool>(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text(ScreenTitles.editYourLabel),
              content: TextField(
                controller: labelController,
                autofocus: true,
                decoration: const InputDecoration(labelText: Labels.enterNewLabel),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(ButtonLabels.cancel),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    // --- Capture navigator inside the async callback ---
                    final navigator = Navigator.of(context);
                    dialogSetState(() => isSaving = true);
                    final success = await _updateGuardianLabel(labelController.text);
                    if (mounted) navigator.pop(success);
                  },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(ButtonLabels.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
  }
  
  void _showEditCaregiverLabelDialog(String caregiverId, String currentLabel) async {
    final labelController = TextEditingController(text: currentLabel);
    await showDialog<bool>(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text(ScreenTitles.editYourLabel),
              content: TextField(
                controller: labelController,
                autofocus: true,
                decoration: const InputDecoration(labelText: Labels.enterNewLabel),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(ButtonLabels.cancel),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    // --- Capture navigator inside the async callback ---
                    final navigator = Navigator.of(context);
                    dialogSetState(() => isSaving = true);
                    if (_aviaryId != null && labelController.text.trim().isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('aviaries')
                          .doc(_aviaryId)
                          .collection('caregivers')
                          .doc(caregiverId)
                          .update({'label': labelController.text.trim()});
                      if (mounted) navigator.pop(true);
                    } else {
                      if (mounted) navigator.pop(false);
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(ButtonLabels.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Widget _caregiverList(String aviaryId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('aviaries').doc(aviaryId).collection('caregivers').snapshots(),
      builder: (context, caregiverSnapshot) {
        if (!caregiverSnapshot.hasData) return const SizedBox.shrink();
        final caregivers = caregiverSnapshot.data!.docs;
        return Column(
          children: caregivers.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isCurrentUser = doc.id == currentUser.uid;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(data['label'] ?? AppStrings.secondaryUser),
                subtitle: Text(data['email'] ?? doc.id),
                trailing: isCurrentUser
                    ? IconButton(
                        icon: const Icon(Icons.edit_note),
                        tooltip: Labels.editYourLabelTooltip,
                        onPressed: () {
                          _showEditCaregiverLabelDialog(doc.id, data['label'] ?? '');
                        },
                      )
                    : null,
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
        if (snapshot.hasError) return const SizedBox.shrink();
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
                subtitle: const Text(AppStrings.invitationPending),
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
      appBar: AppBar(title: const Text(ScreenTitles.manageHousehold)),
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
                    return const Center(child: Text(AppStrings.errorLoadingData));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text(AppStrings.noDataFound));
                  }

                  final aviaryDoc = snapshot.data![0] as DocumentSnapshot;
                  if (!aviaryDoc.exists) {
                    return const Center(child: Text(AppStrings.householdNotFound));
                  }

                  final nests = (snapshot.data![1] as QuerySnapshot).docs;
                  final birds = (snapshot.data![2] as QuerySnapshot).docs;
                  final aviaryData = aviaryDoc.data()! as Map<String, dynamic>;
                  final guardianEmail = aviaryData['guardianEmail'] ?? AppStrings.primaryOwner;

                  return ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      _header(context, Labels.yourEnclosures),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text(ButtonLabels.addNewEnclosure),
                          onPressed: _showAddNestDialog,
                        ),
                      ),
                      if (nests.isEmpty)
                        const Card(child: ListTile(title: Text(AppStrings.noEnclosuresCreated)))
                      else
                        ...nests.map((nestDoc) {
                          final nestData = nestDoc.data() as Map<String, dynamic>;
                          final birdCount = birds.where((bird) => bird['nestId'] == nestDoc.id).length;
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.home_work_outlined),
                              title: Text(nestData['name'] ?? AppStrings.unnamedEnclosure),
                              subtitle: Text('$birdCount ${AppStrings.petCountSuffix}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_note),
                                    onPressed: () => _showEditNestDialog(nestDoc.id, nestData['name']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () async {
                                      await _deleteNest(nestDoc.id, birdCount);
                                      if(mounted) setState(() {});
                                    },
                                  ),
                                ],
                              )
                            ),
                          );
                        }),
                      
                      if (nests.length >= 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.swap_horiz_rounded),
                            label: const Text(ButtonLabels.bulkMovePets),
                            onPressed: () async {
                              // --- Capture navigator before the async gap ---
                              final navigator = Navigator.of(context);
                              await navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => BulkMoveScreen(aviaryId: _aviaryId!),
                                ),
                              );
                              if(mounted) setState(() {});
                            },
                          ),
                        ),

                      const SizedBox(height: 24),
                      _header(context, Labels.secondaryUsers),

                      if (isGuardian)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.shield_outlined),
                            title: Text(aviaryData['aviaryName'] ?? Labels.setYourHouseholdName),
                            subtitle: const Text(AppStrings.householdNameSubtitle),
                            trailing: const Icon(Icons.edit_note),
                            onTap: () {
                              _showEditAviaryNameDialog(aviaryData['aviaryName'] ?? '');
                            },
                          ),
                        ),

                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.amber),
                          title: Text(aviaryData['guardianLabel'] ?? guardianEmail),
                          subtitle: Text('${AppStrings.primaryOwner} • $guardianEmail'),
                          trailing: isGuardian
                              ? IconButton(
                                  icon: const Icon(Icons.edit_note),
                                  tooltip: Labels.editYourLabelTooltip,
                                  onPressed: () {
                                    _showEditGuardianLabelDialog(aviaryData['guardianLabel'] ?? '');
                                  },
                                )
                              : null,
                        ),
                      ),
                      _caregiverList(_aviaryId!),
                      if (isGuardian) _pendingInvitesList(_aviaryId!),
                      const SizedBox(height: 16),
                      if (isGuardian)
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text('${ButtonLabels.invite} a ${AppStrings.secondaryUser}'),
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