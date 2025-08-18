import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cockatiel_companion/widgets/log_dialogs/diet_log_dialog.dart';

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
                onTap: () {
                  // TODO: Open Droppings logging dialog/screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('Behavior & Mood'),
                subtitle: const Text('Tap to log behavior'),
                onTap: () {
                  // TODO: Open Behavior logging dialog/screen
                },
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('birds')
                  .doc(widget.birdId)
                  .collection('daily_logs')
                  .doc(DateFormat('yyyy-MM-dd').format(_selectedDate))
                  .collection('diet_entries')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No diet entries logged for this day.'),
                  );
                }

                final dietEntries = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: dietEntries.length,
                  itemBuilder: (context, index) {
                    final entry = dietEntries[index];
                    final data = entry.data() as Map<String, dynamic>;

                    final String foodType = data['foodType'] ?? 'Unknown';
                    final String description = data['description'] ?? 'No description';
                    final String consumption = data['consumptionLevel'] ?? '-';

                    String formattedTime = '';
                    if (data['timestamp'] != null) {
                      // The timestamp from Firestore is a special Timestamp object
                      final timestamp = data['timestamp'] as Timestamp;
                      // Convert it to a normal DateTime object
                      final dateTime = timestamp.toDate();
                      // Format it to show only the time (e.g., 10:30 AM)
                      formattedTime = DateFormat.jm().format(dateTime);
                    }

                    return ListTile(
                      leading: Icon(
                        Icons.restaurant,
                        color: _getColorForConsumption(consumption), // <-- APPLY THE COLOR
                      ),
                      title: Text('$foodType - $description'),
                      subtitle: Text('Consumption: $consumption'),
                      trailing: Text(formattedTime),
                    );
                  },
                );
              },
            ),
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
}