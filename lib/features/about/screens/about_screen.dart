// lib/features/about/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cockatiel_companion/core/constants.dart';

// --- Data Structure for Changelog ---
// Keeping this separate from the UI makes it easy to update.
class ChangelogEntry {
  final String version;
  final List<String> changes;

  ChangelogEntry({required this.version, required this.changes});
}

final List<ChangelogEntry> changelogData = [
  ChangelogEntry(
    version: 'Version 1.2 (Community Update)', // Renamed for clarity
    changes: [
      'Launched the Community Aviary Q&A Forum!',
      'Users can now post "Chirps" with text and images.',
      'Follow interesting questions with the "+1 / Tell Me Too" button.',
      'Mark helpful replies to guide other users.',
      'Engage with a privacy-first identity system (e.g., "Mama Birdie of SpiceBox").',
      'Manage your content by deleting your own Chirps and replies.',
      'Help moderate the community by "Squawking" (reporting) content that violates guidelines.',
      'Added bulk bird-to-nest movement utility.',
      'Enhanced bird profiles with Hatch Day and Gotcha Day.',
      'Implemented swipe-to-dismiss anniversary reminders on the home screen.',
      'Major navigation refactor with a new bottom bar.',
    ],
  ),
  ChangelogEntry(
    version: 'Version 1.1',
    changes: [
      'Added Guardian & Caregiver custom labels and fixed permissions.',
      'Added Species and Nest assignment to bird profiles.',
      'Added ability to manage Nests (cages) in the Aviary.',
      'Improved the user sign-up and login flow.',
      'Enabled editing and deleting of daily log entries.',
      'Added the "About FlockWell" screen.',
    ],
  ),
  ChangelogEntry(
    version: 'Version 1.0 (MVP)',
    changes: [
      'Initial release of FlockWell!',
      'User Authentication (Email & Google).',
      'Bird Profile creation.',
      'Smart Daily Log for diet, droppings, behavior, and weight.',
      'Guided "First 30 Days" onboarding plan.',
      'Care Task management.',
      'Curated Knowledge Center.',
      'Multi-user foundation for Aviaries, Nests, and Caregivers.',
    ],
  ),
];
// --- End of Data Structure ---


class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${Labels.version} ${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.aboutApp),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Header Section ---
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(AssetPaths.logo),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _version,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          const Divider(height: 40),

          // --- Changelog Section ---
          Text(
            Labels.whatsNew,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...changelogData.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.version,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...entry.changes.map((change) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                      title: Text(change),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}