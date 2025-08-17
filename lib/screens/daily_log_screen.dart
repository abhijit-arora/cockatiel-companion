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
            child: Center(
              child: Text('Log entries for the selected date will go here.'),
            ),
          ),
        ],
      ),
    );
  }
}