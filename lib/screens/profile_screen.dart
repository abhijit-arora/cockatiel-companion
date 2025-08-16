import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    // Get the currently logged-in user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // This should not happen if they got to this screen, but it's good practice to check
      print('Error: No user is logged in.');
      return;
    }

    // Get the bird's name from the controller
    final birdName = _nameController.text.trim();

    // Simple validation: ensure the name is not empty
    if (birdName.isEmpty) {
      print('Error: Bird name cannot be empty.');
      // Later, we can show a user-friendly error message here
      return;
    }

    try {
      // Access our 'birds' collection and add a new document
      await FirebaseFirestore.instance.collection('birds').add({
        'name': birdName,
        'gotchaDay': null, // We'll add the date picker logic later
        'ownerId': user.uid, // This links the bird to the current user
        'createdAt': FieldValue.serverTimestamp(), // Sets the creation time
      });

      print('Profile saved successfully!');

      // After saving, go back to the previous screen (HomePage)
      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      print('Error saving profile: $e');
      // Handle potential Firestore errors here
    }
  }
}