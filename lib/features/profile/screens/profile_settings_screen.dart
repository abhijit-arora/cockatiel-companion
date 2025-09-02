// lib/features/profile/screens/profile_settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/about/screens/about_screen.dart';
import 'package:cockatiel_companion/features/aviary/screens/aviary_management_screen.dart';
import 'package:cockatiel_companion/features/care_tasks/screens/care_tasks_screen.dart';
import 'package:cockatiel_companion/features/knowledge_center/screens/knowledge_center_screen.dart';
import 'package:cockatiel_companion/features/user/services/user_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String _authorLabel = 'Loading...';
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadAuthorLabel();
  }

  Future<void> _loadAuthorLabel() async {
    if (_currentUser == null) {
      setState(() => _authorLabel = 'Not logged in');
      return;
    }
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
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        children: [
          // --- PROFILE HEADER ---
          UserAccountsDrawerHeader(
            accountName: Text(
              _authorLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(_currentUser?.email ?? 'No email associated'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              foregroundColor: Theme.of(context).colorScheme.primary,
              // TODO: Replace with user's actual profile picture
              child: const Icon(Icons.person, size: 48),
            ),
          ),

          // --- SETTINGS LIST ---
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
              // --- Capture navigator BEFORE the async gap of showDialog ---
              final navigator = Navigator.of(context);

              // Show a confirmation dialog before signing out
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog( // Use a different name for the builder's context
                  title: const Text('Confirm Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
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
                // Use the captured navigator AFTER all async gaps
                navigator.popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}