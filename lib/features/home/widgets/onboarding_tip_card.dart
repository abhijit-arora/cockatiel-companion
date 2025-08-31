// lib/features/home/widgets/onboarding_tip_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/core/constants.dart';

class OnboardingTipCard extends StatelessWidget {
  final String birdName;
  final Timestamp gotchaDay;

  const OnboardingTipCard({super.key, required this.birdName,required this.gotchaDay});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final gotchaDate = gotchaDay.toDate();
    final dayNumber = now.difference(gotchaDate).inDays + 1;

    if (dayNumber < 1 || dayNumber > 30) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('onboarding_tips')
          .doc(dayNumber.toString())
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final tipData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Labels.tipFor} $birdName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  tipData['title'] ?? AppStrings.tipOfTheDay,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(tipData['content'] ?? AppStrings.noTipContent),
              ],
            ),
          ),
        );
      },
    );
  }
}