import 'package:flutter/material.dart';

class AviaryManagementScreen extends StatelessWidget {
  const AviaryManagementScreen({super.key});

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
          // We will show a list of invited caregivers here
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Invite a Caregiver'),
              onPressed: () {
                // TODO: Open the invite caregiver dialog
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
}