// lib/features/notifications/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/profile/widgets/settings_action_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.notifications),
        // --- NEW: Add the settings action button ---
        actions: const [
          SettingsActionButton(),
        ],
      ),
      body: const Center(
        child: Text(
          AppStrings.notificationInboxComingSoon,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}