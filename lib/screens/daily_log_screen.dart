import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:cockatiel_companion/widgets/log_dialogs/diet_log_dialog.dart';
import 'package:cockatiel_companion/widgets/log_dialogs/droppings_log_dialog.dart';
import 'package:cockatiel_companion/widgets/log_dialogs/behavior_log_dialog.dart';
import 'package:cockatiel_companion/widgets/log_dialogs/weight_log_dialog.dart';

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
    final String foodType = data['foodType'] ?? 'Unknown';
    final String description = data['description'] ?? 'No description';
    final String consumption = data['consumptionLevel'] ?? '-';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: Icon(Icons.restaurant, color: _getColorForConsumption(consumption)),
      title: Text('$foodType - $description'),
      subtitle: Text('Consumption: $consumption • $formattedTime'), // <-- Time moved here
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Important to keep the row compact
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
      title: const Text('Droppings Observation'),
      subtitle: Text('Color: $color, Consistency: $consistency • $formattedTime'), // <-- Time moved here
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Important to keep the row compact
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
      title: Text('Mood: $mood'),
      subtitle: Text('${behaviors.join(', ')} • $formattedTime'), // <-- Time moved here
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Important to keep the row compact
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
      title: Text('Weight: $weight $unit'),
      subtitle: Text('${data['context'] ?? 'Unspecified'} • $formattedTime'), // <-- Time moved here
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Important to keep the row compact
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
    switch (consumptionLevel) {
      case 'Ate Well': return Colors.green;
      case 'Ate Some': return Colors.orange;
      case 'Untouched': return Colors.red;
      default: return Colors.grey;
    }
  }

  // --- Dialog Functions ---

  Future<void> _showDietLogDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => DietLogDialog(onSave: _saveDietLog),
    );
  }

  Future<void> _showDroppingsLogDialog() async {
    showDialog(
      context: context,
      builder: (context) => DroppingsLogDialog(onSave: _saveDroppingsLog),
    );
  }

  Future<void> _showBehaviorLogDialog() async {
    showDialog(
      context: context,
      builder: (context) => BehaviorLogDialog(onSave: _saveBehaviorLog),
    );
  }

  Future<void> _showWeightLogDialog() async {
    showDialog(
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
      print('Error updating diet log: $e');
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
      print('Error updating droppings log: $e');
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
      print('Error updating behavior log: $e');
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
      print('Error updating weight log: $e');
    }
  }
  
  void _showEditDietDialog(Map<String, dynamic> initialData, String docId) {
    showDialog(
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
  }
  
  void _showEditDroppingsDialog(Map<String, dynamic> initialData, String docId) {
    showDialog(
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
  }
  
  void _showEditBehaviorDialog(Map<String, dynamic> initialData, String docId) {
    showDialog(
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
  }
  
  void _showEditWeightDialog(Map<String, dynamic> initialData, String docId) {
    showDialog(
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
      print('Error saving diet log: $e');
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
      print('Error saving droppings log: $e');
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
      print('Error saving behavior log: $e');
    }
  }
  
  Future<void> _saveWeightLog({ required double weight, required String unit, required String context, required String notes }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final logDocRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId).collection('daily_logs').doc(logDateId);
    try {
      await logDocRef.collection('weight_entries').add({
        'weight': weight, 'unit': unit, 'context': context, 'notes': notes,
        'timestamp': FieldValue.serverTimestamp(), 'birdId': widget.birdId,
      });
      await logDocRef.set({}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving weight log: $e');
    }
  }

  Future<void> _deleteLogEntry(String collectionName, String docId) async {
    // Show a confirmation dialog before deleting
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this log entry? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // If the user confirmed, proceed with deletion
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
            const SnackBar(content: Text('Entry deleted.')),
          );
        }
      } catch (e) {
        print('Error deleting entry: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Could not delete entry.')),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Define and create the stream directly in the build method.
    // This ensures it rebuilds with the new date every time setState is called.
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
        title: Text('${widget.birdName}\'s Daily Log'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // This triggers a rebuild, which re-creates the stream with fresh data.
          setState(() {});
          // Add a small delay for better UX
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            // --- Date Selector Row ---
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

            // --- ACTION LIST ---
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: const Text('Diet'),
                  subtitle: const Text('Tap to log food intake'),
                  onTap: () async { // <-- Make async
                    await _showDietLogDialog(); // Wait for the dialog to close
                    setState(() {}); // Then force a rebuild
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_heart),
                  title: const Text('Droppings'),
                  subtitle: const Text('Tap to log health observations'),
                  onTap: () async { // <-- Make async
                    await _showDroppingsLogDialog();
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.psychology),
                  title: const Text('Behavior & Mood'),
                  subtitle: const Text('Tap to log behavior'),
                  onTap: () async { // <-- Make async
                    await _showBehaviorLogDialog();
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.scale),
                  title: const Text('Weight'),
                  subtitle: const Text('Tap to log weight'),
                  onTap: () async { // <-- Make async
                    await _showWeightLogDialog();
                    setState(() {});
                  },
                ),
              ],
            ),
            
            const Divider(),

            // --- DISPLAY LIST ---
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: combinedLogStream, // Call a function to build the stream
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No entries logged for this day.'));
                  }
                  final logEntries = snapshot.data!;
                  return ListView.builder(
                    itemCount: logEntries.length,
                    itemBuilder: (context, index) {
                      final entry = logEntries[index]; // Use the logEntries list
                      final entryType = entry['type'];
                      final docId = entry['id']; // <-- Get the ID from the map

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
                          return const ListTile(title: Text('Unknown log type'));
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