import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BulkMoveScreen extends StatefulWidget {
  final String aviaryId;
  const BulkMoveScreen({super.key, required this.aviaryId});

  @override
  State<BulkMoveScreen> createState() => _BulkMoveScreenState();
}

class _BulkMoveScreenState extends State<BulkMoveScreen> {
  String? _sourceNestId;
  String? _destinationNestId;

  // Data holders
  List<DropdownMenuItem<String>> _nestOptions = [];
  List<DocumentSnapshot> _sourceBirds = [];

  // State management
  final Map<String, bool> _selectedBirds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNests();
  }

  // --- DATA FETCHING LOGIC ---
  Future<void> _fetchNests() async {
    setState(() => _isLoading = true);
    try {
      final nestsSnapshot = await FirebaseFirestore.instance
          .collection('aviaries')
          .doc(widget.aviaryId)
          .collection('nests')
          .get();

      final nestItems = nestsSnapshot.docs.map((doc) {
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(doc.data()['name'] ?? 'Unnamed Nest'),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _nestOptions = nestItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching nests: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchBirdsForSourceNest(String nestId) async {
    setState(() {
      _sourceBirds = []; // Clear previous birds immediately
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in");
      }

      final birdsSnapshot = await FirebaseFirestore.instance
          .collection('birds')
          // This first clause is still good for scoping to the correct Aviary.
          .where('ownerId', isEqualTo: widget.aviaryId)
          // This new clause is ESSENTIAL for security rules to pass.
          .where('viewers', arrayContains: user.uid)
          .where('nestId', isEqualTo: nestId)
          .get();

      if (mounted) {
        setState(() {
          _sourceBirds = birdsSnapshot.docs;
          // No need to set loading to false here, it's done in the finally block
        });
      }
    } catch (e) {
      print('Error fetching birds: $e');
      // Handle error state if necessary
    } finally {
      // This will run whether the try succeeds or fails.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- UI ACTION LOGIC ---
  Future<void> _moveBirds() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    // Filter the map to get a list of just the bird IDs that were checked.
    final List<String> selectedBirdIds = _selectedBirds.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (_destinationNestId == null || selectedBirdIds.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('No destination or no birds selected.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get a reference to the Firestore database.
      final firestore = FirebaseFirestore.instance;
      // Create a new batch.
      final batch = firestore.batch();

      // For each selected bird ID, add an update operation to the batch.
      for (final birdId in selectedBirdIds) {
        final birdRef = firestore.collection('birds').doc(birdId);
        batch.update(birdRef, {'nestId': _destinationNestId});
      }

      // Commit the batch. This sends all the updates to the server at once.
      await batch.commit();

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${selectedBirdIds.length} bird(s) moved successfully!')),
      );
      
      // Pop the screen to return to the Aviary Management screen.
      navigator.pop();

    } catch (e) {
      print('Error moving birds: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('An error occurred. Could not move birds.')),
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
        title: const Text('Bulk Move Birds'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- SOURCE NEST DROPDOWN ---
                  DropdownButtonFormField<String>(
                    initialValue: _sourceNestId,
                    decoration: const InputDecoration(
                      labelText: 'Move Birds FROM',
                      border: OutlineInputBorder(),
                    ),
                    items: _nestOptions,
                    onChanged: (value) {
                      setState(() {
                        _sourceNestId = value;
                        _destinationNestId = null; // Clear destination
                        _selectedBirds.clear(); // Clear selections
                      });
                      if (value != null) {
                        _fetchBirdsForSourceNest(value);
                      }
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: Icon(Icons.arrow_downward_rounded)),
                  ),

                  // --- DESTINATION NEST DROPDOWN ---
                  DropdownButtonFormField<String>(
                    initialValue: _destinationNestId,
                    decoration: const InputDecoration(
                      labelText: 'Move Birds TO',
                      border: OutlineInputBorder(),
                    ),
                    // Filter out the source nest from the options
                    items: _nestOptions.where((item) => item.value != _sourceNestId).toList(),
                    onChanged: (value) {
                      setState(() => _destinationNestId = value);
                    },
                  ),

                  const Divider(height: 32),

                  // --- BIRD SELECTION LIST ---
                  Text('Select birds to move:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _sourceNestId == null
                        ? const Center(child: Text('Please select a source nest.'))
                        // If loading, show indicator. If not loading and no birds, show message.
                        : _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _sourceBirds.isEmpty
                                ? const Center(child: Text('No birds found in this nest.'))
                                : ListView.builder(
                                    itemCount: _sourceBirds.length,
                            itemBuilder: (context, index) {
                              final bird = _sourceBirds[index];
                              final birdId = bird.id;
                              final birdName = (bird.data() as Map<String, dynamic>)['name'] ?? 'Unnamed Bird';
                              
                              return CheckboxListTile(
                                title: Text(birdName),
                                value: _selectedBirds[birdId] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedBirds[birdId] = value!;
                                  });
                                },
                              );
                            },
                          ),
                  ),

                  // --- ACTION BUTTON ---
                  ElevatedButton.icon(
                    icon: const Icon(Icons.move_up_rounded),
                    label: const Text('Move Selected Birds'),
                    onPressed: (_sourceNestId == null || _destinationNestId == null || _selectedBirds.values.every((v) => !v))
                        ? null // Disable button if conditions aren't met
                        : _moveBirds,
                  ),
                ],
              ),
            ),
    );
  }
}