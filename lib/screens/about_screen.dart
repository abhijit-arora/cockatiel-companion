import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

// --- Data Structure for Changelog ---
// Keeping this separate from the UI makes it easy to update.
class ChangelogEntry {
  final String version;
  final List<String> changes;

  ChangelogEntry({required this.version, required this.changes});
}

final List<ChangelogEntry> changelogData = [
  ChangelogEntry(
    version: 'Version 1.1 (In Progress)',
    changes: [
      'Added Species and Nest assignment to bird profiles.',
      'Added ability to manage Nests (cages) in the Aviary.',
      'Improved the user sign-up and login flow.',
      'Enabled editing and deleting of daily log entries.',
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
      _version = 'Version ${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About FlockWell'),
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
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'FlockWell',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _version,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your AI-assisted companion for raising happy and healthy birds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          const Divider(height: 40),

          // --- Changelog Section ---
          Text(
            'What\'s New',
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
                  }).toList(),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}