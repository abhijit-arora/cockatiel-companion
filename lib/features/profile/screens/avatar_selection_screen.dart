// lib/features/profile/screens/avatar_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:multiavatar/multiavatar.dart';
import 'dart:math';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  List<String> _avatars = [];
  String? _selectedAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateAvatars();
  }

  void _generateAvatars() {
    setState(() {
      _avatars = List.generate(12, (index) {
        // Generate a random string to create a unique avatar
        final randomString = String.fromCharCodes(
          List.generate(10, (_) => Random().nextInt(26) + 65),
        );
        return multiavatar(randomString);
      });
      _selectedAvatar = null; // Clear selection
    });
  }

  Future<void> _saveAvatar() async { // Make the method async
    if (_selectedAvatar == null) return;
    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('saveUserAvatar');
      await callable.call({'avatarSvg': _selectedAvatar!});
      
      navigator.pop(); // Go back to the settings screen
    } on FirebaseFunctionsException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not save avatar.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Avatar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateAvatars,
            tooltip: 'Generate New Avatars',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _avatars.length,
              itemBuilder: (context, index) {
                final avatarSvg = _avatars[index];
                final isSelected = _selectedAvatar == avatarSvg;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatarSvg;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            )
                          : null,
                    ),
                    child: SvgPicture.string(avatarSvg),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedAvatar == null || _isLoading ? null : _saveAvatar,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Avatar'),
            ),
          ),
        ],
      ),
    );
  }
}