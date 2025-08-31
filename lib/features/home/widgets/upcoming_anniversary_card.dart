// lib/features/home/widgets/upcoming_anniversary_card.dart
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

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
      countdownText = "${AppStrings.anniversaryTodayPrefix} ${eventName.toLowerCase()}${AppStrings.anniversaryTodaySuffix}";
      iconData = Icons.cake;
    } else if (daysRemaining == 1) {
      countdownText = '1 ${AppStrings.anniversarySingularPrefix} ${eventName.toLowerCase()}${AppStrings.anniversarySuffix}';
      iconData = Icons.celebration;
    } else {
      countdownText = '$daysRemaining ${AppStrings.anniversaryPluralPrefix} ${eventName.toLowerCase()}${AppStrings.anniversarySuffix}';
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
        title: Text('${Labels.upcoming} $birdName\'s $eventName'),
        subtitle: Text(countdownText),
      ),
    );
  }
}