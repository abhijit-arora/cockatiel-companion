import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// We reuse the category list from the main community screen.
const List<String> _categories = [
  'Health & Wellness',
  'Behavior & Training',
  'Nutrition & Diet',
  'Cage, Toys & Gear',
  'General Chat',
];

class CreateChirpScreen extends StatefulWidget {
  final String? initialCategory;
  const CreateChirpScreen({super.key, this.initialCategory});

  @override
  State<CreateChirpScreen> createState() => _CreateChirpScreenState();
}

class _CreateChirpScreenState extends State<CreateChirpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _selectedCategory;
  final ImagePicker _picker = ImagePicker();
  XFile? _mediaFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // If an initial category was passed, set it as the default.
    if (widget.initialCategory != null && _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory;
    }
  }

  Future<void> _submitChirp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      String? mediaUrl;

      // --- 1. UPLOAD MEDIA IF IT EXISTS ---
      if (_mediaFile != null) {
        // Create a unique file path.
        final filePath = 'community_media/${user.uid}/${DateTime.now().millisecondsSinceEpoch}-${_mediaFile!.name}';
        final storageRef = FirebaseStorage.instance.ref().child(filePath);

        // Upload the file.
        final uploadTask = await storageRef.putData(await _mediaFile!.readAsBytes());

        // Get the public download URL.
        mediaUrl = await uploadTask.ref.getDownloadURL();
      }

      // --- 2. PREPARE CHIRP DATA ---
      final authorLabel = await _getAuthorLabel(user);
      final chirpData = {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'category': _selectedCategory,
        'authorId': user.uid,
        'authorLabel': authorLabel,
        'createdAt': FieldValue.serverTimestamp(),
        'replyCount': 0,
        'upvoteCount': 0,
        'mediaUrl': mediaUrl, // Can be null if no media was attached
      };

      // --- 3. SAVE CHIRP TO FIRESTORE ---
      await FirebaseFirestore.instance.collection('community_chirps').add(chirpData);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error submitting chirp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<String> _getAuthorLabel(User user) async {
    // Determine the user's aviary ID
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    String aviaryId;
    bool isGuardian = true;

    if (userDoc.exists && userDoc.data()!.containsKey('partOfAviary')) {
      aviaryId = userDoc.data()!['partOfAviary'];
      isGuardian = false;
    } else {
      aviaryId = user.uid;
    }

    // Fetch the Aviary document to get the aviaryName
    final aviaryDoc = await FirebaseFirestore.instance.collection('aviaries').doc(aviaryId).get();
    final aviaryName = aviaryDoc.data()?['aviaryName'] ?? 'An Aviary';

    // Fetch the user's specific label
    String userLabel;
    if (isGuardian) {
      userLabel = aviaryDoc.data()?['guardianLabel'] ?? user.email ?? 'Guardian';
    } else {
      final caregiverDoc = await FirebaseFirestore.instance
          .collection('aviaries')
          .doc(aviaryId)
          .collection('caregivers')
          .doc(user.uid)
          .get();
      userLabel = caregiverDoc.data()?['label'] ?? user.email ?? 'Caregiver';
    }

    return '$userLabel of $aviaryName';
  }

  Future<void> _pickMedia(ImageSource source) async {
    // For now, we allow both images and videos. We will add the duration check later.
    final XFile? pickedFile = await _picker.pickMedia();

    if (pickedFile != null) {
      setState(() {
        _mediaFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Chirp'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitChirp,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category*',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title / Question*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body (Optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attach Media (Optional)', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_mediaFile != null)
                      // Display a preview of the selected media
                      Text('Selected: ${_mediaFile!.name}')
                    else
                      const Text('No file selected.'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          onPressed: () => _pickMedia(ImageSource.gallery),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          onPressed: () => _pickMedia(ImageSource.camera),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}