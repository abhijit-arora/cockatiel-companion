import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

          // --- Log Entries Section ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                // We will make these functional one by one
                ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: const Text('Diet'),
                  subtitle: const Text('Tap to log food intake'),
                  onTap: _showDietLogDialog,
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
          ),
        ],
      ),
    );
  }

  void _showDietLogDialog() {
    final _descriptionController = TextEditingController();
    final _notesController = TextEditingController();
    String _selectedFoodType = 'Pellets'; // Default
    String _consumptionLevel = 'Normal'; // Default

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a StatefulWidget to manage the state within the dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Log Food Offered'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Dropdown for Food Type
                    DropdownButtonFormField<String>(
                      value: _selectedFoodType,
                      items: ['Pellets', 'Vegetables', 'Fruit', 'Sprouts', 'Treat', 'Other']
                          .map((label) => DropdownMenuItem(child: Text(label), value: label))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedFoodType = value!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Food Type'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (e.g., Fresh chop)'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Consumption Level'),
                    // ChoiceChips for codified consumption
                    Wrap(
                      spacing: 8.0,
                      children: ['Untouched', 'Ate Some', 'Ate Well'].map((level) {
                        return ChoiceChip(
                          label: Text(level),
                          selected: _consumptionLevel == level,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                _consumptionLevel = level;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    // Call the save function with the data from the dialog
                    _saveDietLog(
                      foodType: _selectedFoodType,
                      description: _descriptionController.text,
                      consumptionLevel: _consumptionLevel,
                      notes: _notesController.text,
                    );
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
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