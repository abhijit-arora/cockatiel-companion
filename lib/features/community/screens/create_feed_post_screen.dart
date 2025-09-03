// lib/features/community/screens/create_feed_post_screen.dart
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CreateFeedPostScreen extends StatefulWidget {
  const CreateFeedPostScreen({super.key});
  @override
  State<CreateFeedPostScreen> createState() => _CreateFeedPostScreenState();
}

class _CreateFeedPostScreenState extends State<CreateFeedPostScreen> {
  final _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _mediaFile;
  // ignore: prefer_final_fields
  bool _isSubmitting = false;

  Future<void> _pickMedia(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickMedia();
    if (pickedFile != null) {
      setState(() {
        _mediaFile = pickedFile;
      });
    }
  }

  // --- REVISED SUBMIT METHOD ---
  Future<void> _submitPost() async {
    if (_mediaFile == null && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.postValidationError)),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Should not happen if they got here

    setState(() => _isSubmitting = true);

    try {
      String? uploadedMediaUrl;

      // --- 1. UPLOAD MEDIA IF IT EXISTS ---
      if (_mediaFile != null) {
        final filePath = 'feed_media/${user.uid}/${DateTime.now().millisecondsSinceEpoch}-${_mediaFile!.name}';
        final storageRef = FirebaseStorage.instance.ref().child(filePath);
        // Read file data as bytes. This is compatible with web and mobile.
        final Uint8List fileData = await _mediaFile!.readAsBytes();
        // Upload the data.
        final uploadTask = await storageRef.putData(fileData);
        // Get the public URL.
        uploadedMediaUrl = await uploadTask.ref.getDownloadURL();
      }

      // --- 2. CALL THE CLOUD FUNCTION ---
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createFeedPost');
      await callable.call({
        'body': _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
        'mediaUrl': uploadedMediaUrl,
      });

      // --- 3. NAVIGATE BACK ON SUCCESS ---
      navigator.pop();

    } catch (e) {
      debugPrint('Error creating feed post: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${AppStrings.saveError} ${e.toString()}')),
      );
    } finally {
      if(mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.createFeedPost),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
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
        child: Column(
          children: [
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: Labels.captionOptional,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
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
                children: [
                  const Text('Media (Optional)'),
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
    );
  }
}