// lib/features/user/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cockatiel_companion/core/constants.dart';

class UserService {
  /// Fetches the currently logged-in user's formatted author label.
  /// Example: "Mama Birdie of The Blue Angels"
  static Future<String> getAuthorLabelForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AppStrings.anonymous;
    }

    final firestore = FirebaseFirestore.instance;

    // Determine the user's aviary ID
    final userDoc = await firestore.collection('users').doc(user.uid).get();
    String aviaryId;
    bool isGuardian = true;

    if (userDoc.exists && userDoc.data()!.containsKey('partOfAviary')) {
      aviaryId = userDoc.data()!['partOfAviary'];
      isGuardian = false;
    } else {
      aviaryId = user.uid;
    }

    // Fetch the Aviary document to get the aviaryName
    final aviaryDoc = await firestore.collection('aviaries').doc(aviaryId).get();
    final aviaryName = aviaryDoc.data()?['aviaryName'] ?? AppStrings.defaultHouseholdName;

    // Fetch the user's specific label based on their role
    String userLabel;
    if (isGuardian) {
      userLabel = aviaryDoc.data()?['guardianLabel'] ?? user.email ?? AppStrings.primaryOwner;
    } else {
      final caregiverDoc = await firestore
          .collection('aviaries')
          .doc(aviaryId)
          .collection('caregivers')
          .doc(user.uid)
          .get();
      userLabel = caregiverDoc.data()?['label'] ?? user.email ?? AppStrings.secondaryUser;
    }

    return '$userLabel of $aviaryName';
  }
}