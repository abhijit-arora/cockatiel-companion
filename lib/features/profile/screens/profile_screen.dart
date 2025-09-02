// lib/features/profile/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/features/aviary/widgets/aviary_dialogs/add_edit_nest_dialog.dart';
import 'package:cockatiel_companion/features/notifications/services/notification_service.dart';
import 'package:cockatiel_companion/core/constants.dart';

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
  String? _selectedNestId;
  List<DropdownMenuItem<String>> _nestOptions = [];
  bool _isNestsLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.birdId == null ? ScreenTitles.addPet : ScreenTitles.editPet),
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
                  CircleAvatar(
                    radius: 60,
                    child: const Icon(Icons.photo_camera, size: 50),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement image picking logic
                    },
                    child: const Text(ButtonLabels.addPhotoOptional),
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: Labels.nameRequired,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppStrings.petNameValidation;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  if (_isNestsLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _selectedNestId,
                          decoration: const InputDecoration(
                            labelText: Labels.enclosureRequired,
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
                              return AppStrings.enclosureValidation;
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(Labels.createNewEnclosure),
                            onPressed: _showAddNestDialog,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedSpecies,
                    decoration: const InputDecoration(
                      labelText: Labels.speciesRequired,
                      border: OutlineInputBorder(),
                    ),
                    items: DropdownOptions.petSpecies.map((String species) {
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
                        return AppStrings.speciesValidation;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _gotchaDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: Labels.adoptionDay,
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

                  const SizedBox(height: 16),

                  TextField(
                    controller: _hatchDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: Labels.birthDayOptional,
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.cake_outlined),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedHatchDate ?? _selectedGotchaDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
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

                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text(ButtonLabels.saveProfile),
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
    _fetchNests().then((_) {
      if (widget.birdId != null) {
        _fetchBirdData();
      }
    });
  }

  Future<void> _fetchBirdData() async {
    setState(() { _isLoading = true; });

    try {
      final doc = await FirebaseFirestore.instance.collection('birds').doc(widget.birdId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'];
        _selectedSpecies = data['species'];
        _selectedNestId = data['nestId'];
        if (data['gotchaDay'] != null) {
          final timestamp = data['gotchaDay'] as Timestamp;
          _selectedGotchaDate = timestamp.toDate();
          _gotchaDateController.text = DateFormat.yMMMMd().format(_selectedGotchaDate!);
        }
        if (data['hatchDay'] != null) {
          final timestamp = data['hatchDay'] as Timestamp;
          _selectedHatchDate = timestamp.toDate();
          _hatchDateController.text = DateFormat.yMMMMd().format(_selectedHatchDate!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching bird data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorLoadingData} ${e.toString()}')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
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

      await _fetchNests();
      setState(() {
        _selectedNestId = newNestRef.id;
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('"$name" ${AppStrings.enclosureCreated}')),
      );
    } catch (e) {
      debugPrint('Error adding nest: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${AppStrings.createEnclosureError} ${e.toString()}')),
      );
    }
  }

  void _showAddNestDialog() {
    showDialog(
      context: context,
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
          child: Text(doc.data()['name'] ?? AppStrings.unnamedEnclosure),
        );
      }).toList();

      setState(() {
        _nestOptions = nestItems;
        if (_selectedNestId == null && nestItems.length == 1) {
            _selectedNestId = nestItems.first.value;
        }
      });
    } catch (e) {
      debugPrint('Error fetching nests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorLoadingData} ${e.toString()}')),
        );
      }
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
      debugPrint('Error: No user is logged in.');
      // No SnackBar needed here, as this is a logic guard, not a user-facing error.
      return;
    }
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() { _isLoading = true; });

    try {
      if (_selectedNestId == null) {
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
        
        final newNestRef = await aviaryDocRef.collection('nests').add({
            'name': 'My First Nest',
            'createdAt': FieldValue.serverTimestamp(),
        });
        _selectedNestId = newNestRef.id;
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text(AppStrings.firstEnclosureCreated)),
        );
      }

      final caregiversSnapshot = await FirebaseFirestore.instance
          .collection('aviaries')
          .doc(widget.aviaryId)
          .collection('caregivers')
          .get();
      
      final List<String> viewers = [widget.aviaryId];
      for (var doc in caregiversSnapshot.docs) {
        viewers.add(doc.id);
      }

      final birdData = {
        'name': _nameController.text.trim(),
        'species': _selectedSpecies,
        'gotchaDay': _selectedGotchaDate,
        'hatchDay': _selectedHatchDate,
        'ownerId': widget.aviaryId,
        'nestId': _selectedNestId,
        'viewers': viewers,
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

      await _scheduleNotifications(birdRef.id, birdData);
      
      navigator.pop();

    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('${AppStrings.saveError} ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _scheduleNotifications(String birdId, Map<String, dynamic> birdData) async {
    final notificationService = NotificationService();
    
    final hatchDayId = birdId.hashCode;
    final gotchaDayId = '$birdId-gotcha'.hashCode;

    if (birdData['hatchDay'] != null) {
      await notificationService.scheduleAnniversaryNotification(
        id: hatchDayId,
        title: AppStrings.upcomingBirthDayTitle, // Corrected
        body: '${AppStrings.upcomingBirthDayBodyPart1} ${birdData['name']}${AppStrings.upcomingBirthDayBodyPart2}', // Corrected
        eventDate: birdData['hatchDay'],
      );
    } else {
      await notificationService.cancelNotification(hatchDayId);
    }

    if (birdData['gotchaDay'] != null) {
      await notificationService.scheduleAnniversaryNotification(
        id: gotchaDayId,
        title: AppStrings.upcomingAdoptionDayTitle, // Corrected
        body: '${birdData['name']}${AppStrings.upcomingAdoptionDayBodyPart1} ${AppStrings.upcomingAdoptionDayBodyPart2}', // Corrected
        eventDate: birdData['gotchaDay'],
      );
    } else {
      await notificationService.cancelNotification(gotchaDayId);
    }
  }
}