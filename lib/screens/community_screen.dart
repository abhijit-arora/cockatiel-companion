import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Aviary'),
      ),
      body: const Center(
        child: Text(
          'Community Features Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}