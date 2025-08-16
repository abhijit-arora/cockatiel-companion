import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Bird'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Image Placeholder ---
            CircleAvatar(
              radius: 60,
              child: const Icon(Icons.photo_camera, size: 50),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // TODO: Implement image picking logic
              },
              child: const Text('Add Photo'),
            ),

            const SizedBox(height: 24),

            // --- Name Field ---
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // --- Gotcha Day Field (Placeholder) ---
            TextField(
              readOnly: true, // Makes the field not editable by keyboard
              decoration: const InputDecoration(
                labelText: 'Gotcha Day (Date you got your bird)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                // TODO: Implement date picker logic
              },
            ),

            const SizedBox(height: 24),

            // --- Save Button ---
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save logic
              },
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}