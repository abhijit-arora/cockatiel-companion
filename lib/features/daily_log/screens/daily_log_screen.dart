// lib/features/daily_log/screens/daily_log_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:cockatiel_companion/features/daily_log/widgets/log_dialogs/diet_log_dialog.dart';
import 'package:cockatiel_companion/features/daily_log/widgets/log_dialogs/droppings_log_dialog.dart';
import 'package:cockatiel_companion/features/daily_log/widgets/log_dialogs/behavior_log_dialog.dart';
import 'package:cockatiel_companion/features/daily_log/widgets/log_dialogs/weight_log_dialog.dart';
import 'package:cockatiel_companion/core/constants.dart';

class DailyLogScreen extends StatefulWidget {
  final String birdId;
  final String birdName;

  const DailyLogScreen({
    super.key,
    required this.birdId,
    required this.birdName,
  });

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  DateTime _selectedDate = DateTime.now();

  // --- UI Builder Helper Functions ---

  ListTile _buildDietListTile(Map<String, dynamic> data, String docId) {
    final String foodType = data['foodType'] ?? AppStrings.unknown;
    final String description = data['description'] ?? AppStrings.noDescription;
    final String consumption = data['consumptionLevel'] ?? '-';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: Icon(Icons.restaurant, color: _getColorForConsumption(consumption)),
      title: Text('$foodType - $description'),
      subtitle: Text('${Labels.consumption} $consumption • $formattedTime'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              _showEditDietDialog(data, docId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _deleteLogEntry('diet_entries', docId);
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildDroppingsListTile(Map<String, dynamic> data, String docId) {
    final String color = data['color'] ?? '-';
    final String consistency = data['consistency'] ?? '-';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: const Icon(Icons.monitor_heart, color: Colors.brown),
      title: Text(AppStrings.droppingsObservation),
      subtitle: Text('${Labels.color} $color, ${Labels.consistency} $consistency • $formattedTime'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              _showEditDroppingsDialog(data, docId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _deleteLogEntry('droppings_entries', docId);
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildBehaviorListTile(Map<String, dynamic> data, String docId) {
    final List<dynamic> behaviors = data['behaviors'] ?? [];
    final String mood = data['mood'] ?? '-';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: const Icon(Icons.psychology, color: Colors.blue),
      title: Text('${Labels.mood} $mood'),
      subtitle: Text('${behaviors.join(', ')} • $formattedTime'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              _showEditBehaviorDialog(data, docId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _deleteLogEntry('behavior_entries', docId);
            },
          ),
        ],
      ),
    );
  }
  
  ListTile _buildWeightListTile(Map<String, dynamic> data, String docId) {
    final double weight = (data['weight'] ?? 0.0).toDouble();
    final String unit = data['unit'] ?? 'g';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: const Icon(Icons.scale, color: Colors.teal),
      title: Text('${Labels.weight} $weight $unit'),
      subtitle: Text('${data['context'] ?? AppStrings.unspecifiedContext} • $formattedTime'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              _showEditWeightDialog(data, docId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _deleteLogEntry('weight_entries', docId);
            },
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = (timestamp as Timestamp).toDate();
    return DateFormat.jm().format(dt);
  }

  Color _getColorForConsumption(String consumptionLevel) {
    if (consumptionLevel == DropdownOptions.dietConsumptionLevels[0]) { // Ate Well
      return Colors.green;
    } else if (consumptionLevel == DropdownOptions.dietConsumptionLevels[1]) { // Ate Some
      return Colors.orange;
    } else if (consumptionLevel == DropdownOptions.dietConsumptionLevels[2]) { // Untouched
      return Colors.red;
    }
    return Colors.grey;
  }

  // --- Dialog Functions ---

  Future<void> _showDietLogDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => DietLogDialog(onSave: _saveDietLog),
    );
  }

  Future<void> _showDroppingsLogDialog() async {
    await showDialog(
      context: context,
      builder: (context) => DroppingsLogDialog(onSave: _saveDroppingsLog),
    );
  }

  Future<void> _showBehaviorLogDialog() async {
    await showDialog(
      context: context,
      builder: (context) => BehaviorLogDialog(onSave: _saveBehaviorLog),
    );
  }

  Future<void> _showWeightLogDialog() async {
    await showDialog(
      context: context,
      builder: (context) => WeightLogDialog(onSave: _saveWeightLog),
    );
  }

  // --- Update Functions ---
  
  Future<void> _updateDietLog({
    required String docId, // <-- We need the ID of the document to update
    required String foodType,
    required String description,
    required String consumptionLevel,
    required String notes,
  }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      await FirebaseFirestore.instance
          .collection('birds').doc(widget.birdId)
          .collection('daily_logs').doc(logDateId)
          .collection('diet_entries').doc(docId) // <-- Use the docId
          .update({ // <-- Use .update()
        'foodType': foodType,
        'description': description,
        'consumptionLevel': consumptionLevel,
        'notes': notes,
      });
    } catch (e) {
      debugPrint('Error updating diet log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.updateError)),
        );
      }
    }
  }
  
  Future<void> _updateDroppingsLog({
    required String docId,
    required String color,
    required String consistency,
    required String notes,
  }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      await FirebaseFirestore.instance
          .collection('birds').doc(widget.birdId)
          .collection('daily_logs').doc(logDateId)
          .collection('droppings_entries').doc(docId)
          .update({
        'color': color,
        'consistency': consistency,
        'notes': notes,
      });
    } catch (e) {
      debugPrint('Error updating droppings log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.updateError)),
        );
      }
    }
  }
  
  Future<void> _updateBehaviorLog({
    required String docId,
    required List<String> behaviors,
    required String mood,
    required String notes,
  }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      await FirebaseFirestore.instance
          .collection('birds').doc(widget.birdId)
          .collection('daily_logs').doc(logDateId)
          .collection('behavior_entries').doc(docId)
          .update({
        'behaviors': behaviors,
        'mood': mood,
        'notes': notes,
      });
    } catch (e) {
      debugPrint('Error updating behavior log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.updateError)),
        );
      }
    }
  }
  
  Future<void> _updateWeightLog({
    required String docId,
    required double weight,
    required String unit,
    required String context,
    required String notes,
  }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      await FirebaseFirestore.instance
          .collection('birds').doc(widget.birdId)
          .collection('daily_logs').doc(logDateId)
          .collection('weight_entries').doc(docId)
          .update({
        'weight': weight,
        'unit': unit,
        'context': context,
        'notes': notes,
      });
    } catch (e) {
      debugPrint('Error updating weight log: $e');
      // We will add the SnackBar in a later refactor for all errors.
    }
  }
  
  void _showEditDietDialog(Map<String, dynamic> initialData, String docId) async {
    await showDialog(
      context: context,
      builder: (context) => DietLogDialog(
        initialData: initialData,
        onSave: ({required foodType, required description, required consumptionLevel, required notes}) {
          // Add "return" to pass the Future back
          return _updateDietLog(
            docId: docId,
            foodType: foodType,
            description: description,
            consumptionLevel: consumptionLevel,
            notes: notes,
          );
        },
      ),
    );
    setState(() {});
  }
  
  void _showEditDroppingsDialog(Map<String, dynamic> initialData, String docId) async {
    await showDialog(
      context: context,
      builder: (context) => DroppingsLogDialog(
        initialData: initialData,
        onSave: ({required color, required consistency, required notes}) {
          return _updateDroppingsLog(
            docId: docId,
            color: color,
            consistency: consistency,
            notes: notes,
          );
        },
      ),
    );
    setState(() {});
  }

  void _showEditBehaviorDialog(Map<String, dynamic> initialData, String docId) async {
    await showDialog(
      context: context,
      builder: (context) => BehaviorLogDialog(
        initialData: initialData,
        onSave: ({required behaviors, required mood, required notes}) {
          return _updateBehaviorLog(
            docId: docId,
            behaviors: behaviors,
            mood: mood,
            notes: notes,
          );
        },
      ),
    );
    setState(() {});
  }

  void _showEditWeightDialog(Map<String, dynamic> initialData, String docId) async {
    await showDialog(
      context: context,
      builder: (context) => WeightLogDialog(
        initialData: initialData,
        onSave: ({required weight, required unit, required context, required notes}) {
          return _updateWeightLog(
            docId: docId,
            weight: weight,
            unit: unit,
            context: context,
            notes: notes,
          );
        },
      ),
    );
    setState(() {});
  }
  
  // --- Firestore Save Functions ---

  Future<void> _saveDietLog({ required String foodType, required String description, required String consumptionLevel, required String notes }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final logDocRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId).collection('daily_logs').doc(logDateId);
    try {
      await logDocRef.collection('diet_entries').add({
        'foodType': foodType, 'description': description, 'consumptionLevel': consumptionLevel, 'notes': notes,
        'timestamp': FieldValue.serverTimestamp(), 'birdId': widget.birdId,
      });
      await logDocRef.set({}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving diet log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
    }
  }

  Future<void> _saveDroppingsLog({ required String color, required String consistency, required String notes }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final logDocRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId).collection('daily_logs').doc(logDateId);
    try {
      await logDocRef.collection('droppings_entries').add({
        'color': color, 'consistency': consistency, 'notes': notes, 'imageUrl': null,
        'timestamp': FieldValue.serverTimestamp(), 'birdId': widget.birdId,
      });
      await logDocRef.set({}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving droppings log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
    }
  }
  
  Future<void> _saveBehaviorLog({ required List<String> behaviors, required String mood, required String notes }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final logDocRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId).collection('daily_logs').doc(logDateId);
    try {
      await logDocRef.collection('behavior_entries').add({
        'behaviors': behaviors, 'mood': mood, 'notes': notes,
        'timestamp': FieldValue.serverTimestamp(), 'birdId': widget.birdId,
      });
      await logDocRef.set({}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving behavior log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
    }
  }
  
  Future<void> _saveWeightLog({
    required double weight,
    required String unit,
    required String context,
    required String notes,
  }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final logDocRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId).collection('daily_logs').doc(logDateId);
    try {
      await logDocRef.collection('weight_entries').add({
        'weight': weight,
        'unit': unit,
        'context': context,
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(),
        'birdId': widget.birdId,
      });
      await logDocRef.set({}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving weight log: $e');
      // We will add the SnackBar in a later refactor for all errors.
    }
  }

  Future<void> _deleteLogEntry(String collectionName, String docId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(ScreenTitles.confirmDeletion),
          content: const Text(AppStrings.confirmLogDeletionMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(ButtonLabels.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(ButtonLabels.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
        await FirebaseFirestore.instance
            .collection('birds')
            .doc(widget.birdId)
            .collection('daily_logs')
            .doc(logDateId)
            .collection(collectionName)
            .doc(docId)
            .delete();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.entryDeleted)),
          );
        }
      } catch (e) {
        debugPrint('Error deleting entry: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.deleteError)),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyLogRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId).collection('daily_logs').doc(logDateId);

    Stream<QuerySnapshot> dietStream = dailyLogRef.collection('diet_entries').snapshots();
    Stream<QuerySnapshot> droppingsStream = dailyLogRef.collection('droppings_entries').snapshots();
    Stream<QuerySnapshot> behaviorStream = dailyLogRef.collection('behavior_entries').snapshots();
    Stream<QuerySnapshot> weightStream = dailyLogRef.collection('weight_entries').snapshots();

    final Stream<List<Map<String, dynamic>>> combinedLogStream = StreamZip([
      dietStream, droppingsStream, behaviorStream, weightStream
    ]).map((results) {
      final allDocs = [
        ...results[0].docs.map((doc) => {'type': 'diet', 'id': doc.id, ...doc.data() as Map<String, dynamic>}),
        ...results[1].docs.map((doc) => {'type': 'droppings', 'id': doc.id, ...doc.data() as Map<String, dynamic>}),
        ...results[2].docs.map((doc) => {'type': 'behavior', 'id': doc.id, ...doc.data() as Map<String, dynamic>}),
        ...results[3].docs.map((doc) => {'type': 'weight', 'id': doc.id, ...doc.data() as Map<String, dynamic>}),
      ];
      allDocs.sort((a, b) {
        Timestamp tsA = a['timestamp'] ?? Timestamp.fromMicrosecondsSinceEpoch(0);
        Timestamp tsB = b['timestamp'] ?? Timestamp.fromMicrosecondsSinceEpoch(0);
        return tsB.compareTo(tsA);
      });
      return allDocs;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.birdName}${ScreenTitles.dailyLogSuffix}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).primaryColorLight,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context, initialDate: _selectedDate,
                        firstDate: DateTime(2000), lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Row(
                      children: [
                        Text(DateFormat.yMMMMd().format(_selectedDate), style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.today),
                    onPressed: () => setState(() => _selectedDate = DateTime.now()),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      final today = DateTime.now();
                      if (_selectedDate.year == today.year && _selectedDate.month == today.month && _selectedDate.day == today.day) {
                        return;
                      }
                      setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                    },
                  ),
                ],
              ),
            ),

            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: const Text(Labels.diet),
                  subtitle: Text(AppStrings.logDietSubtitle), 
                  onTap: () async {
                    await _showDietLogDialog();
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_heart),
                  title: const Text(Labels.droppings),
                  subtitle: Text(AppStrings.logDroppingsSubtitle),
                  onTap: () async {
                    await _showDroppingsLogDialog();
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.psychology),
                  title: const Text(Labels.behaviorAndMood),
                  subtitle: Text(AppStrings.logBehaviorSubtitle),
                  onTap: () async {
                    await _showBehaviorLogDialog();
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.scale),
                  title: const Text(Labels.weight),
                  subtitle: Text(AppStrings.logWeightSubtitle),
                  onTap: () async {
                    await _showWeightLogDialog();
                    setState(() {});
                  },
                ),
              ],
            ),
            
            const Divider(),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: combinedLogStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('${AppStrings.errorPrefix} ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text(AppStrings.noLogEntries));
                  }
                  final logEntries = snapshot.data!;
                  return ListView.builder(
                    itemCount: logEntries.length,
                    itemBuilder: (context, index) {
                      final entry = logEntries[index];
                      final entryType = entry['type'];
                      final docId = entry['id'];

                      switch (entryType) {
                        case 'diet':
                          return _buildDietListTile(entry, docId);
                        case 'droppings':
                          return _buildDroppingsListTile(entry, docId);
                        case 'behavior':
                          return _buildBehaviorListTile(entry, docId);
                        case 'weight':
                          return _buildWeightListTile(entry, docId);
                        default:
                          return const ListTile(title: Text(AppStrings.unknownLogType));
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}