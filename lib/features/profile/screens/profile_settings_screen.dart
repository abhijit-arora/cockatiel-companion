// lib/features/profile/screens/profile_settings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/about/screens/about_screen.dart';
import 'package:cockatiel_companion/features/aviary/screens/aviary_management_screen.dart';
import 'package:cockatiel_companion/features/care_tasks/screens/care_tasks_screen.dart';
import 'package:cockatiel_companion/features/knowledge_center/screens/knowledge_center_screen.dart';
import 'package:cockatiel_companion/features/user/services/user_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cockatiel_companion/features/profile/screens/avatar_selection_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String _authorLabel = Labels.loading;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String? _aviaryId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      setState(() => _authorLabel = Labels.notLoggedIn);
      return;
    }
    _aviaryId = await UserService.findAviaryIdForCurrentUser();
    final label = await UserService.getAuthorLabelForCurrentUser();
    if (mounted) {
      setState(() {
        _authorLabel = label;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.profileAndSettings),
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _authorLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(_currentUser?.email ?? Labels.noEmail),
            currentAccountPicture: GestureDetector(
              // --- CORRECTED: This now navigates to the AvatarSelectionScreen ---
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AvatarSelectionScreen()),
                );
              },
              child: StreamBuilder<DocumentSnapshot>(
                stream: _aviaryId != null
                    ? FirebaseFirestore.instance.collection('aviaries').doc(_aviaryId).snapshots()
                    : null,
                builder: (context, snapshot) {
                  String? avatarSvg;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    avatarSvg = data['avatarSvg'];
                  }
                  
                  return CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    // The display logic is still correct
                    child: avatarSvg != null
                        ? SvgPicture.string(avatarSvg)
                        : const Icon(Icons.person, size: 48),
                  );
                },
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.group_work_outlined),
            title: const Text(ScreenTitles.manageHousehold),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AviaryManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: const Text(ScreenTitles.careTasks),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CareTasksScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text(ScreenTitles.knowledgeCenter),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const KnowledgeCenterScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(ScreenTitles.aboutApp),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(Labels.signOut, style: TextStyle(color: Colors.red)),
            onTap: () async {
              final navigator = Navigator.of(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text(ScreenTitles.confirmSignOut),
                  content: const Text(Labels.areYouSureSignOut),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(ButtonLabels.cancel),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(Labels.signOut),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await FirebaseAuth.instance.signOut();
                navigator.popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}