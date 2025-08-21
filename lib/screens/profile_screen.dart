import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final String? birdId;
  const ProfileScreen({super.key, this.birdId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gotchaDateController = TextEditingController();
  DateTime? _selectedGotchaDate;
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
            child: Form(
              key: _formKey,
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
                  TextFormField( // <-- CHANGE TO TextFormField
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name*', // Add asterisk for clarity
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your bird\'s name.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // --- Gotcha Day Field ---
                  TextField(
                    controller: _gotchaDateController, // <-- Use the new controller
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Gotcha Day (Date you got your bird)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async { // <-- Implement onTap
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedGotchaDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedGotchaDate = picked;
                          // Use our intl package to format the date nicely
                          _gotchaDateController.text = DateFormat.yMMMMd().format(picked);
                        });
                      }
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
        if (data['gotchaDay'] != null) {
          // Convert the Firestore Timestamp back to a DateTime
          final timestamp = data['gotchaDay'] as Timestamp;
          _selectedGotchaDate = timestamp.toDate();
          _gotchaDateController.text = DateFormat.yMMMMd().format(_selectedGotchaDate!);
        }
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
    // 1. Validate the form first.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Get the current user.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Error: No user is logged in.');
      return;
    }
    
    // Capture the navigator before the async gap.
    final navigator = Navigator.of(context);

    setState(() { _isLoading = true; });

    try {
      // 3. Get or create the user's Aviary and a default Nest.
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final nestsCollectionRef = userDocRef.collection('nests');
      
      DocumentReference nestRef;
      
      final nestsSnapshot = await nestsCollectionRef.limit(1).get();

      if (nestsSnapshot.docs.isEmpty) {
        // First time saving a bird, let's create the user doc and the nest.
        await userDocRef.set({
          'guardianEmail': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        nestRef = await nestsCollectionRef.add({
          'name': 'My First Nest',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // User and nest already exist, just get the reference to the first nest.
        nestRef = nestsSnapshot.docs.first.reference;
      }

      // 4. Prepare the bird data.
      final birdData = {
        'name': _nameController.text.trim(),
        'gotchaDay': _selectedGotchaDate,
        'ownerId': user.uid,
        'nestId': nestRef.id,
      };

      // 5. Create or Update the bird document.
      if (widget.birdId == null) {
        // CREATE: Also include the 'createdAt' timestamp.
        await FirebaseFirestore.instance.collection('birds').add({
          ...birdData,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Profile CREATED successfully!');
      } else {
        // UPDATE: Do NOT include 'createdAt'.
        await FirebaseFirestore.instance.collection('birds').doc(widget.birdId).update(birdData);
        print('Profile UPDATED successfully!');
      }
      
      navigator.pop();

    } catch (e) {
      print('Error saving profile: $e');
    } finally {
      // Ensure the loading spinner is always turned off.
      if(mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }
}