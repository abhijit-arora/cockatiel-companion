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

  ListTile _buildDietListTile(Map<String, dynamic> data) {
    final String foodType = data['foodType'] ?? 'Unknown';
    final String description = data['description'] ?? 'No description';
    final String consumption = data['consumptionLevel'] ?? '-';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: Icon(Icons.restaurant, color: _getColorForConsumption(consumption)),
      title: Text('$foodType - $description'),
      subtitle: Text('Consumption: $consumption'),
      trailing: Text(formattedTime),
    );
  }

  ListTile _buildDroppingsListTile(Map<String, dynamic> data) {
    final String color = data['color'] ?? '-';
    final String consistency = data['consistency'] ?? '-';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: const Icon(Icons.monitor_heart, color: Colors.brown),
      title: const Text('Droppings Observation'),
      subtitle: Text('Color: $color, Consistency: $consistency'),
      trailing: Text(formattedTime),
    );
  }

  ListTile _buildBehaviorListTile(Map<String, dynamic> data) {
    final List<dynamic> behaviors = data['behaviors'] ?? [];
    final String mood = data['mood'] ?? '-';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: const Icon(Icons.psychology, color: Colors.blue),
      title: Text('Mood: $mood'),
      subtitle: Text(behaviors.join(', ')),
      trailing: Text(formattedTime),
    );
  }
  
  ListTile _buildWeightListTile(Map<String, dynamic> data) {
    final double weight = (data['weight'] ?? 0.0).toDouble();
    final String unit = data['unit'] ?? 'g';
    final formattedTime = _formatTimestamp(data['timestamp']);

    return ListTile(
      leading: const Icon(Icons.scale, color: Colors.teal),
      title: Text('Weight: $weight $unit'),
      subtitle: Text(data['context'] ?? 'Unspecified'),
      trailing: Text(formattedTime),
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
        ...results[0].docs.map((doc) => {'type': 'diet', ...doc.data() as Map<String, dynamic>}),
        ...results[1].docs.map((doc) => {'type': 'droppings', ...doc.data() as Map<String, dynamic>}),
        ...results[2].docs.map((doc) => {'type': 'behavior', ...doc.data() as Map<String, dynamic>}),
        ...results[3].docs.map((doc) => {'type': 'weight', ...doc.data() as Map<String, dynamic>}),
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
                      final entry = logEntries[index];
                      final String type = entry['type'];
                      switch (type) {
                        case 'diet': return _buildDietListTile(entry);
                        case 'droppings': return _buildDroppingsListTile(entry);
                        case 'behavior': return _buildBehaviorListTile(entry);
                        case 'weight': return _buildWeightListTile(entry);
                        default: return const ListTile(title: Text('Unknown log type'));
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