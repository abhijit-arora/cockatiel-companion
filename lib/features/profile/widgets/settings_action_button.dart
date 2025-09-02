// lib/features/profile/widgets/settings_action_button.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/profile/screens/profile_settings_screen.dart';

class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: 'Settings', // This will not be themed for now
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfileSettingsScreen(),
          ),
        );
      },
    );
  }
}