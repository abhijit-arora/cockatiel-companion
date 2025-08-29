import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OnboardingTipCard extends StatelessWidget {
  final String birdName;
  final Timestamp gotchaDay;

  const OnboardingTipCard({super.key, required this.birdName,required this.gotchaDay});

  @override
  Widget build(BuildContext context) {
    // 1. Calculate the current day of ownership
    final now = DateTime.now();
    final gotchaDate = gotchaDay.toDate();
    // Add 1 because the difference will be 0 on the first day
    final dayNumber = now.difference(gotchaDate).inDays + 1;

    // Don't show the card after 30 days
    if (dayNumber < 1 || dayNumber > 30) {
      return const SizedBox.shrink(); // An empty, invisible widget
    }

    return FutureBuilder<DocumentSnapshot>(
      // 2. Fetch the specific tip for the calculated day number
      future: FirebaseFirestore.instance
          .collection('onboarding_tips')
          .doc(dayNumber.toString())
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // If there's no tip for today, show nothing
          return const SizedBox.shrink();
        }

        final tipData = snapshot.data!.data() as Map<String, dynamic>;

        // 3. Display the tip in a nice card
        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A new, smaller "pre-header" for the bird's name
                Text(
                  'Tip for $birdName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54, // A slightly more subtle color
                  ),
                ),
                // The main title of the tip
                Text(
                  tipData['title'] ?? 'Tip of the Day',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(tipData['content'] ?? 'No tip content available.'),
              ],
            ),
          ),
        );
      },
    );
  }
}