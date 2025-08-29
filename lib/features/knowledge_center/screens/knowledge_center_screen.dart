import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KnowledgeCenterScreen extends StatefulWidget {
  const KnowledgeCenterScreen({super.key});

  @override
  State<KnowledgeCenterScreen> createState() => _KnowledgeCenterScreenState();
}

class _KnowledgeCenterScreenState extends State<KnowledgeCenterScreen> {
  // Helper function to get the right icon based on resource type
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
        title: const Text('Knowledge Center'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('resources').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No resources found.'));
          }

          final resources = snapshot.data!.docs;

          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              final data = resource.data() as Map<String, dynamic>;

              return ListTile(
                leading: Icon(_getIconForType(data['type'] ?? '')),
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(data['sourceName'] ?? 'Unknown Source'),
                onTap: () async {
                  final url = data['url'];
                  if (url != null) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      // Show an error message if the URL can't be launched
                      if (mounted) { // <-- ADD THIS CHECK
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not launch $url')),
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