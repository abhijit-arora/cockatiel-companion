// lib/features/community/screens/create_chirp_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:cockatiel_companion/features/user/services/user_service.dart';

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

  final List<String> _categories = DropdownOptions.communityCategories;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && _categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory;
    }
  }

  Future<void> _submitChirp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // --- Capture context-dependent objects BEFORE the async gap ---
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.mustBeLoggedInToPost)),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      String? mediaUrl;
      if (_mediaFile != null) {
        final filePath = 'community_media/${user.uid}/${DateTime.now().millisecondsSinceEpoch}-${_mediaFile!.name}';
        final storageRef = FirebaseStorage.instance.ref().child(filePath);
        final uploadTask = await storageRef.putData(await _mediaFile!.readAsBytes());
        mediaUrl = await uploadTask.ref.getDownloadURL();
      }

      // --- Use the UserService ---
      final authorLabel = await UserService.getAuthorLabelForCurrentUser();
  
      final chirpData = {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'category': _selectedCategory,
        'authorId': user.uid,
        'authorLabel': authorLabel,
        'createdAt': FieldValue.serverTimestamp(),
        'replyCount': 0,
        // NOTE: I am removing the 'upvoteCount' field from an older version that doesn't exist anymore.
        // It was a typo in one of my earlier refactors.
        'mediaUrl': mediaUrl,
      };

      // --- NEW DEBUGGING STATEMENT ---
      debugPrint("Attempting to create Chirp with data: $chirpData");

      final newChirpRef = await FirebaseFirestore.instance.collection('community_chirps').add(chirpData);

      final chirpFollowersRef = newChirpRef.collection('followers').doc(user.uid);
      await chirpFollowersRef.set({'followedAt': FieldValue.serverTimestamp()});
      await newChirpRef.update({'followerCount': 1});

      if (mounted) {
        navigator.pop();
      }
    } catch (e) {
      debugPrint('Error submitting chirp: $e');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('${AppStrings.genericError}: ${e.toString()}')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickMedia(ImageSource source) async {
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
        title: const Text(ScreenTitles.createPost),
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
                  : const Text(ButtonLabels.post),
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
                  labelText: Labels.category,
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
                validator: (value) => value == null ? AppStrings.categoryValidation : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: Labels.postTitle,
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? AppStrings.titleValidation : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: Labels.postBody,
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
                    Text(Labels.attachMedia, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_mediaFile != null)
                      Text('${AppStrings.selectedFile} ${_mediaFile!.name}')
                    else
                      const Text(AppStrings.noFileSelected),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text(ButtonLabels.gallery),
                          onPressed: () => _pickMedia(ImageSource.gallery),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text(ButtonLabels.camera),
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