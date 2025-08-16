import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/screens/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Cockatiel Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Define the query to fetch the bird profile
        stream: FirebaseFirestore.instance
            .collection('birds')
            .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // --- 1. Handle Loading State ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 2. Handle Error State ---
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          // --- 3. Handle "No Data" State ---
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have no birds yet. Add one!'),
            );
          }

          // --- 4. Handle "Has Data" State ---
          // If we get here, it means we have data!
          final birdDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: birdDocs.length,
            itemBuilder: (context, index) {
              // Get the individual bird document
              final birdDocument = birdDocs[index];
              final birdName = birdDocument['name'] as String;
              final birdId = birdDocument.id;

              // Display it in a nice list tile
              return ListTile(
                leading: const Icon(Icons.star_border),
                title: Text(birdName),
                onTap: () {
                  // Navigate to the ProfileScreen in "Edit Mode"
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(birdId: birdId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}