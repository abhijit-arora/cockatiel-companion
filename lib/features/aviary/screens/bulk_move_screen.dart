// lib/features/aviary/screens/bulk_move_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cockatiel_companion/core/constants.dart';

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
          child: Text(doc.data()['name'] ?? AppStrings.unnamedEnclosure),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _nestOptions = nestItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching nests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorLoadingData} ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
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
        throw Exception(AppStrings.noUserLoggedIn);
      }

      final birdsSnapshot = await FirebaseFirestore.instance
          .collection('birds')
          .where('ownerId', isEqualTo: widget.aviaryId)
          .where('viewers', arrayContains: user.uid)
          .where('nestId', isEqualTo: nestId)
          .get();

      if (mounted) {
        setState(() {
          _sourceBirds = birdsSnapshot.docs;
        });
      }
    } catch (e) {
      debugPrint('Error fetching birds: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorLoadingData} ${e.toString()}')),
        );
      }
    } finally {
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

    final List<String> selectedBirdIds = _selectedBirds.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (_destinationNestId == null || selectedBirdIds.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.noDestinationOrPetsSelected)),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final birdId in selectedBirdIds) {
        final birdRef = firestore.collection('birds').doc(birdId);
        batch.update(birdRef, {'nestId': _destinationNestId});
      }

      await batch.commit();

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${selectedBirdIds.length} ${AppStrings.petsMovedSuccessfully}')),
      );
      
      navigator.pop();

    } catch (e) {
      debugPrint('Error moving birds: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${AppStrings.movePetsError} ${e.toString()}')),
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
        title: const Text(ScreenTitles.bulkMovePets),
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
                      labelText: Labels.movePetsFrom,
                      border: OutlineInputBorder(),
                    ),
                    items: _nestOptions,
                    onChanged: (value) {
                      setState(() {
                        _sourceNestId = value;
                        _destinationNestId = null;
                        _selectedBirds.clear();
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
                      labelText: Labels.movePetsTo,
                      border: OutlineInputBorder(),
                    ),
                    items: _nestOptions.where((item) => item.value != _sourceNestId).toList(),
                    onChanged: (value) {
                      setState(() => _destinationNestId = value);
                    },
                  ),

                  const Divider(height: 32),

                  // --- BIRD SELECTION LIST ---
                  Text(Labels.selectPetsToMove, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _sourceNestId == null
                        ? const Center(child: Text(AppStrings.selectSourceEnclosure))
                        : _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _sourceBirds.isEmpty
                                ? const Center(child: Text(AppStrings.noPetsInEnclosure))
                                : ListView.builder(
                                    itemCount: _sourceBirds.length,
                            itemBuilder: (context, index) {
                              final bird = _sourceBirds[index];
                              final birdId = bird.id;
                              final birdName = (bird.data() as Map<String, dynamic>)['name'] ?? AppStrings.unnamedPet;
                              
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
                    label: const Text(ButtonLabels.moveSelectedPets),
                    onPressed: (_sourceNestId == null || _destinationNestId == null || _selectedBirds.values.every((v) => !v))
                        ? null
                        : _moveBirds,
                  ),
                ],
              ),
            ),
    );
  }
}