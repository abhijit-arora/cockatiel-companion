import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String? birdId;
  const ProfileScreen({super.key, this.birdId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.birdId == null ? 'Add to Your Flock' : 'Edit Profile'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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

  @override
  void initState() {
    super.initState();
    // Check if we are in "Edit Mode"
    if (widget.birdId != null) {
      // If so, fetch the data for that bird
      _fetchBirdData();
    }
  }

  Future<void> _fetchBirdData() async {
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance.collection('birds').doc(widget.birdId).get();
      if (doc.exists) {
        final data = doc.data()!;
        // Set the text of our controller with the fetched name
        _nameController.text = data['name'];
      }
    } catch (e) {
      print('Error fetching bird data: $e');
      // Handle errors later
    } finally {
      // Set loading state to false once done
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Error: No user is logged in.');
      return;
    }

    final birdName = _nameController.text.trim();

    if (birdName.isEmpty) {
      print('Error: Bird name cannot be empty.');
      return;
    }

    try {
      // --- THIS IS THE NEW LOGIC ---
      if (widget.birdId == null) {
        // CREATE MODE: Add a new document
        await FirebaseFirestore.instance.collection('birds').add({
          'name': birdName,
          'gotchaDay': null,
          'ownerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Profile created successfully!');
      } else {
        // EDIT MODE: Update an existing document
        await FirebaseFirestore.instance.collection('birds').doc(widget.birdId).update({
          'name': birdName,
          // We can add other fields to update here later
        });
        print('Profile updated successfully!');
      }
      // --- END OF NEW LOGIC ---

      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      print('Error saving profile: $e');
    }
  }
}