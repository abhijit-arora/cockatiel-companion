import 'package:flutter/material.dart';

class UpcomingAnniversaryCard extends StatelessWidget {
  final String birdName;
  final String eventName;
  final int daysRemaining;

  const UpcomingAnniversaryCard({
    super.key,
    required this.birdName,
    required this.eventName,
    required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    String countdownText;
    IconData iconData;

    if (daysRemaining == 0) {
      countdownText = "It's today! Happy ${eventName.toLowerCase()}!";
      iconData = Icons.cake;
    } else if (daysRemaining == 1) {
      countdownText = '1 day to go until their ${eventName.toLowerCase()}!';
      iconData = Icons.celebration;
    } else {
      countdownText = '$daysRemaining days to go until their ${eventName.toLowerCase()}!';
      iconData = Icons.calendar_today;
    }

    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: ListTile(
        leading: Icon(
          iconData,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
        title: Text('Upcoming: $birdName\'s $eventName'),
        subtitle: Text(countdownText),
      ),
    );
  }
}