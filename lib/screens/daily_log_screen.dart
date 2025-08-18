import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:cockatiel_companion/widgets/log_dialogs/diet_log_dialog.dart';
import 'package:cockatiel_companion/widgets/log_dialogs/droppings_log_dialog.dart';
import 'package:cockatiel_companion/widgets/log_dialogs/behavior_log_dialog.dart';

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
      leading: const Icon(Icons.monitor_heart, color: Colors.brown), // Example color
      title: Text('Droppings Observation'),
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
  
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = (timestamp as Timestamp).toDate();
    return DateFormat.jm().format(dt);
  }

  Stream<List<Map<String, dynamic>>>? _combinedLogStream;

  @override
  void initState() {
    super.initState();
    _setupCombinedStream();
  }

  @override
  void didUpdateWidget(covariant DailyLogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupCombinedStream();
  }

  void _setupCombinedStream() {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dailyLogRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId).collection('daily_logs').doc(logDateId);

    Stream<QuerySnapshot> dietStream = dailyLogRef.collection('diet_entries').snapshots();
    Stream<QuerySnapshot> droppingsStream = dailyLogRef.collection('droppings_entries').snapshots();
    Stream<QuerySnapshot> behaviorStream = dailyLogRef.collection('behavior_entries').snapshots();        

    // Combine the streams
    _combinedLogStream = StreamZip([dietStream, droppingsStream, behaviorStream]).map((results) {
      final dietDocs = results[0].docs;
      final droppingsDocs = results[1].docs;
      final behaviorDocs = results[2].docs;

      // Convert each document to a map and add a 'type' field
      List<Map<String, dynamic>> combinedList = [];
      for (var doc in dietDocs) {
        combinedList.add({'type': 'diet', ...doc.data() as Map<String, dynamic>});
      }
      for (var doc in droppingsDocs) {
        combinedList.add({'type': 'droppings', ...doc.data() as Map<String, dynamic>});
      }
      for (var doc in behaviorDocs) {
        combinedList.add({'type': 'behavior', ...doc.data() as Map<String, dynamic>});
      }

      // Sort the combined list by timestamp
      combinedList.sort((a, b) {
        Timestamp tsA = a['timestamp'] ?? Timestamp.now();
        Timestamp tsB = b['timestamp'] ?? Timestamp.now();
        return tsB.compareTo(tsA); // descending
      });

      return combinedList;
    });
  }

  Color _getColorForConsumption(String consumptionLevel) {
    switch (consumptionLevel) {
      case 'Ate Well':
        return Colors.green;
      case 'Ate Some':
        return Colors.orange;
      case 'Untouched':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.birdName}\'s Daily Log'),
      ),
      body: Column(
        children: [
          // --- Date Selector Row ---
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).primaryColorLight,
            child: Row(
              children: [
                // PREVIOUS DAY BUTTON
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                      _setupCombinedStream();
                    });
                  },
                ),
                // SPACER to push everything else to the right
                const Spacer(),
                
                // A new Row to group the date and today button together
                Row(
                  children: [
                    // DATE DISPLAY AND PICKER
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                            _setupCombinedStream();
                          });
                        }
                      },
                      child: Text(
                        DateFormat.yMMMMd().format(_selectedDate),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    // GO TO TODAY BUTTON (now next to the date)
                    IconButton(
                      icon: const Icon(Icons.today),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime.now();
                          _setupCombinedStream();
                        });
                      },
                    ),
                  ],
                ),
                
                // SPACER to push the next day button to the far right
                const Spacer(),
                
                // NEXT DAY BUTTON
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    if (_selectedDate.day == DateTime.now().day &&
                        _selectedDate.month == DateTime.now().month &&
                        _selectedDate.year == DateTime.now().year) return;
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                      _setupCombinedStream();
                    });
                  },
                ),
              ],
            ),
          ),

          // --- ACTION LIST: For entering new data ---
          // This is a static list of options for the user.
          ListView(
            shrinkWrap: true, // Important to make it work inside a Column
            padding: const EdgeInsets.all(8.0),
            children: [
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Diet'),
                subtitle: const Text('Tap to log food intake'),
                onTap: _showDietLogDialog, // This is already implemented
              ),
              ListTile(
                leading: const Icon(Icons.monitor_heart),
                title: const Text('Droppings'),
                subtitle: const Text('Tap to log health observations'),
                onTap: _showDroppingsLogDialog, // <-- Update this
              ),
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('Behavior & Mood'),
                subtitle: const Text('Tap to log behavior'),
                onTap: _showBehaviorLogDialog,
              ),
              ListTile(
                leading: const Icon(Icons.scale),
                title: const Text('Weight'),
                subtitle: const Text('Tap to log weight'),
                onTap: () {
                  // TODO: Open Weight logging dialog/screen
                },
              ),
            ],
          ),
          
          const Divider(), // A visual separator

          // --- DISPLAY LIST: For showing saved entries ---
          // This is a dynamic list that reads from Firestore.
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _combinedLogStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No entries logged for this day.'),
                  );
                }

                final logEntries = snapshot.data!;

                return ListView.builder(
                  itemCount: logEntries.length,
                  itemBuilder: (context, index) {
                    final entry = logEntries[index];
                    final String type = entry['type'];
                    
                    // Use a switch statement to build the correct widget
                    switch (type) {
                      case 'diet':
                        return _buildDietListTile(entry);
                      case 'droppings':
                        return _buildDroppingsListTile(entry);
                      case 'behavior':
                        return _buildBehaviorListTile(entry);
                      default:
                        return const ListTile(title: Text('Unknown log type'));
                    }
                  },
                );
              },
            )
          ),
        ],
      ),
    );
  }

  void _showDietLogDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DietLogDialog(
          onSave: _saveDietLog, // <-- Pass the actual save function
        );
      },
    );
  }

  Future<void> _saveDietLog({
    required String foodType,
    required String description,
    required String consumptionLevel,
    required String notes,
  }) async {
    // 1. Get a reference to the daily log document for the selected date.
    // The document ID will be the date itself in 'YYYY-MM-DD' format.
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final logDocRef = FirebaseFirestore.instance
        .collection('birds')
        .doc(widget.birdId)
        .collection('daily_logs')
        .doc(logDateId);

    // 2. Add a new document to the 'diet_entries' sub-collection.
    try {
      await logDocRef.collection('diet_entries').add({
        'foodType': foodType,
        'description': description,
        'consumptionLevel': consumptionLevel,
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(),
        // For the MVP, we assume the log applies to the current bird.
        // Later, we'll add the 'sharedWith' field here.
        'birdId': widget.birdId,
      });

      print('Diet log saved successfully!');

      // 3. We also use .set({}, SetOptions(merge: true)) on the parent logDocRef.
      // This is a clever trick: if the daily_log document for this date doesn't
      // exist yet, this will create it. If it already exists, it does nothing.
      // This ensures we always have a parent document for our sub-collections.
      await logDocRef.set({}, SetOptions(merge: true));

    } catch (e) {
      print('Error saving diet log: $e');
      // Handle errors later
    }
  }

  void _showDroppingsLogDialog() {
    showDialog(
      context: context,
      builder: (context) => DroppingsLogDialog(onSave: _saveDroppingsLog),
    );
  }

  Future<void> _saveDroppingsLog({
    required String color,
    required String consistency,
    required String notes,
  }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final logDocRef = FirebaseFirestore.instance
        .collection('birds')
        .doc(widget.birdId)
        .collection('daily_logs')
        .doc(logDateId);

    try {
      await logDocRef.collection('droppings_entries').add({
        'color': color,
        'consistency': consistency,
        'notes': notes,
        'imageUrl': null, // For future use
        'timestamp': FieldValue.serverTimestamp(),
        'birdId': widget.birdId,
      });
      await logDocRef.set({}, SetOptions(merge: true));
      print('Droppings log saved successfully!');
    } catch (e) {
      print('Error saving droppings log: $e');
    }
  }

  void _showBehaviorLogDialog() {
    showDialog(
      context: context,
      builder: (context) => BehaviorLogDialog(onSave: _saveBehaviorLog),
    );
  }
  
  Future<void> _saveBehaviorLog({
    required List<String> behaviors,
    required String mood,
    required String notes,
  }) async {
    final logDateId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final logDocRef = FirebaseFirestore.instance.collection('birds').doc(widget.birdId).collection('daily_logs').doc(logDateId);

    try {
      await logDocRef.collection('behavior_entries').add({
        'behaviors': behaviors,
        'mood': mood,
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(),
        'birdId': widget.birdId,
      });
      await logDocRef.set({}, SetOptions(merge: true));
      print('Behavior log saved successfully!');
    } catch (e) {
      print('Error saving behavior log: $e');
    }
  }
}