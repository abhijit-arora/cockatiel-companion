// lib/features/knowledge_center/screens/knowledge_center_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cockatiel_companion/core/constants.dart';

class KnowledgeCenterScreen extends StatefulWidget {
  const KnowledgeCenterScreen({super.key});

  @override
  State<KnowledgeCenterScreen> createState() => _KnowledgeCenterScreenState();
}

class _KnowledgeCenterScreenState extends State<KnowledgeCenterScreen> {
  IconData _getIconForType(String type) {
    switch (type) {
      case 'Video':
        return Icons.video_library;
      case 'Article':
        return Icons.article;
      default:
        return Icons.public;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenTitles.knowledgeCenter),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('resources').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text(AppStrings.noResourcesFound));
          }

          final resources = snapshot.data!.docs;

          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              final data = resource.data() as Map<String, dynamic>;

              return ListTile(
                leading: Icon(_getIconForType(data['type'] ?? '')),
                title: Text(data['title'] ?? AppStrings.noTitle),
                subtitle: Text(data['sourceName'] ?? AppStrings.unknownSource),
                onTap: () async {
                  final url = data['url'];
                  // --- Capture context-dependent objects BEFORE the async gap ---
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  if (url != null) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      // The mounted check is still good practice.
                      if (mounted) {
                        scaffoldMessenger.showSnackBar( // Use the captured object
                          SnackBar(content: Text('${AppStrings.couldNotLaunch} $url')),
                        );
                      }
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}