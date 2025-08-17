import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.birdName}\'s Daily Log'),
      ),
      body: const Center(
        child: Text('Daily Log UI will go here.'),
      ),
    );
  }
}