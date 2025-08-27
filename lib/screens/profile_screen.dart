import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/widgets/aviary_dialogs/add_edit_nest_dialog.dart';
import 'package:cockatiel_companion/services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? birdId;
  final String aviaryId;
  const ProfileScreen({super.key, this.birdId, required this.aviaryId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gotchaDateController = TextEditingController();
  DateTime? _selectedGotchaDate;
  final _hatchDateController = TextEditingController();
  DateTime? _selectedHatchDate;
  bool _isLoading = false;
  String? _selectedSpecies;
  final List<String> _speciesOptions = [
    'Cockatiel',
    'Budgerigar',
    'Parrotlet',
    'Lovebird',
    'Conure',
    'Other',
  ];
  String? _selectedNestId;
    List<DropdownMenuItem<String>> _nestOptions = [];
    bool _isNestsLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.birdId == null ? 'Add to Your Flock' : 'Edit Profile'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Image Placeholder ---
                  CircleAvatar(
                    radius: 60,
                    child: const Icon(Icons.photo_camera, size: 50),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement image picking logic
                    },
                    child: const Text('Add Photo'),
                  ),

                  const SizedBox(height: 24),

                  // --- Name Field ---
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your bird\'s name.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // --- Nest Dropdown Field ---
                  if (_isNestsLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column( // Wrap dropdown in a Column
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedNestId,
                          decoration: const InputDecoration(
                            labelText: 'Nest*',
                            border: OutlineInputBorder(),
                          ),
                          items: _nestOptions,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedNestId = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a nest for your bird.';
                            }
                            return null;
                          },
                        ),
                        // Add the button below the dropdown
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Create New Nest'),
                            onPressed: _showAddNestDialog,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // --- Species Dropdown Field ---
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSpecies,
                    decoration: const InputDecoration(
                      labelText: 'Species*',
                      border: OutlineInputBorder(),
                    ),
                    items: _speciesOptions.map((String species) {
                      return DropdownMenuItem<String>(
                        value: species,
                        child: Text(species),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSpecies = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your bird\'s species.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // --- Gotcha Day Field ---
                  TextField(
                    controller: _gotchaDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Gotcha Day (Date you got your bird)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedGotchaDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedGotchaDate = picked;
                          _gotchaDateController.text = DateFormat.yMMMMd().format(picked);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16), // Add some space

                  // --- Hatch Date Field ---
                  TextField(
                    controller: _hatchDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Hatch Day (Optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.cake_outlined), // A more fitting icon
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedHatchDate ?? _selectedGotchaDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(), // Birds can't be hatched in the future
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedHatchDate = picked;
                          _hatchDateController.text = DateFormat.yMMMMd().format(picked);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // --- Save Button ---
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                ],
          ),
            ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // In both "Add" and "Edit" mode, we need the list of nests.
    _fetchNests().then((_) {
      // After nests are fetched, if we are in "Edit Mode", fetch the bird's data.
      if (widget.birdId != null) {
        _fetchBirdData();
      }
    });
  }

  Future<void> _fetchBirdData() async {
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance.collection('birds').doc(widget.birdId).get();
      if (doc.exists) {
        final data = doc.data()!;
        // Set the text of our controller with the fetched name
        _nameController.text = data['name'];
        _selectedSpecies = data['species'];
        _selectedNestId = data['nestId'];
        if (data['gotchaDay'] != null) {
          // Convert the Firestore Timestamp back to a DateTime
          final timestamp = data['gotchaDay'] as Timestamp;
          _selectedGotchaDate = timestamp.toDate();
          _gotchaDateController.text = DateFormat.yMMMMd().format(_selectedGotchaDate!);
        }
        // Add this block to load the hatch date
        if (data['hatchDay'] != null) {
          final timestamp = data['hatchDay'] as Timestamp;
          _selectedHatchDate = timestamp.toDate();
          _hatchDateController.text = DateFormat.yMMMMd().format(_selectedHatchDate!);
        }
      }
    } catch (e) {
      print('Error fetching bird data: $e');
      // Handle errors later
    } finally {
      // Set loading state to false once done
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNest(String name) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final newNestRef = await FirebaseFirestore.instance
          .collection('aviaries')
          .doc(widget.aviaryId)
          .collection('nests')
          .add({'name': name, 'createdAt': FieldValue.serverTimestamp()});

      // After creating the nest, refresh the list and select the new one.
      await _fetchNests();
      setState(() {
        _selectedNestId = newNestRef.id;
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('"$name" has been created!')),
      );
    } catch (e) {
      print('Error adding nest: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error: Could not create the nest.')),
      );
    }
  }

  void _showAddNestDialog() {
    showDialog(
      context: context,
      // We are reusing the existing dialog here.
      builder: (context) => AddEditNestDialog(onSave: _addNest),
    );
  }
  
  Future<void> _fetchNests() async {
    setState(() { _isNestsLoading = true; });
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

      setState(() {
        _nestOptions = nestItems;
        // If there is no nest currently selected, and there's only one option, select it automatically.
        if (_selectedNestId == null && nestItems.length == 1) {
            _selectedNestId = nestItems.first.value;
        }
      });
    } catch (e) {
      print('Error fetching nests: $e');
      // Optionally show an error message to the user
    } finally {
      setState(() { _isNestsLoading = false; });
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Error: No user is logged in.');
      return;
    }
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() { _isLoading = true; });

    try {
      // If no nest is selected (e.g., for a new user), create one.
      if (_selectedNestId == null) {
        // First, ensure the Aviary document exists.
        final aviaryDocRef = FirebaseFirestore.instance.collection('aviaries').doc(widget.aviaryId);
        final aviaryDoc = await aviaryDocRef.get();
        if (!aviaryDoc.exists) {
            final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
            await userDocRef.set({'email': user.email, 'aviaryId': user.uid});
            await aviaryDocRef.set({
                'guardianEmail': user.email,
                'guardianUid': user.uid,
                'createdAt': FieldValue.serverTimestamp(),
            });
        }
        
        // Now, create the default nest and assign its ID.
        final newNestRef = await aviaryDocRef.collection('nests').add({
            'name': 'My First Nest',
            'createdAt': FieldValue.serverTimestamp(),
        });
        _selectedNestId = newNestRef.id;
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Your first nest has been created!')),
        );
      }

      // --- Get all caregivers to add to the viewers list ---
      final caregiversSnapshot = await FirebaseFirestore.instance
          .collection('aviaries')
          .doc(widget.aviaryId)
          .collection('caregivers')
          .get();
      
      // Create a list of viewer UIDs, starting with the Guardian
      final List<String> viewers = [widget.aviaryId];
      // Add all the caregiver UIDs
      for (var doc in caregiversSnapshot.docs) {
        viewers.add(doc.id);
      }

      // --- Prepare and Save the Bird Data ---
      final birdData = {
        'name': _nameController.text.trim(),
        'species': _selectedSpecies,
        'gotchaDay': _selectedGotchaDate,
        'hatchDay': _selectedHatchDate,
        'ownerId': widget.aviaryId,
        'nestId': _selectedNestId,
        'viewers': viewers, // <-- Use the new comprehensive list of viewers
      };

      DocumentReference birdRef;
      if (widget.birdId == null) {
        birdRef = await FirebaseFirestore.instance.collection('birds').add({
          ...birdData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        birdRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId);
        await birdRef.update(birdData);
      }

      // --- NEW: Schedule notifications after saving ---
      await _scheduleNotifications(birdRef.id, birdData);
      
      navigator.pop();

    } catch (e) {
      print('Error saving profile: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _scheduleNotifications(String birdId, Map<String, dynamic> birdData) async {
    final notificationService = NotificationService();
    
    // Create unique IDs for the notifications. 
    // Using a hash of the bird's ID and the type of notification.
    final hatchDayId = birdId.hashCode;
    final gotchaDayId = (birdId + 'gotcha').hashCode;

    // Schedule Hatch Day notification
    if (birdData['hatchDay'] != null) {
      await notificationService.scheduleAnniversaryNotification(
        id: hatchDayId,
        title: 'Upcoming Hatch Day! 🎂',
        body: 'Get ready to celebrate! ${birdData['name']}\'s hatch day is in one week.',
        eventDate: birdData['hatchDay'],
      );
    } else {
      // If the date was removed, cancel any existing notification.
      await notificationService.cancelNotification(hatchDayId);
    }

    // Schedule Gotcha Day notification
    if (birdData['gotchaDay'] != null) {
      await notificationService.scheduleAnniversaryNotification(
        id: gotchaDayId,
        title: 'Upcoming Gotcha Day! 🎉',
        body: '${birdData['name']}\'s gotcha day is in one week! Time to celebrate your journey together.',
        eventDate: birdData['gotchaDay'],
      );
    } else {
      await notificationService.cancelNotification(gotchaDayId);
    }
  }
}