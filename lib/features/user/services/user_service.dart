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
    final aviaryData = aviaryDoc.data() ?? {};
    final aviaryName = aviaryData['aviaryName'] ?? AppStrings.defaultHouseholdName;

    // Fetch the user's specific label based on their role
    String userLabel;
    if (isGuardian) {
      userLabel = aviaryData['guardianLabel'] ?? user.email ?? AppStrings.primaryOwner;
    } else {
      final caregiverDoc = await firestore
          .collection('aviaries')
          .doc(aviaryId)
          .collection('caregivers')
          .doc(user.uid)
          .get();
      final caregiverData = caregiverDoc.data() ?? {};
      userLabel = caregiverData['label'] ?? user.email ?? AppStrings.secondaryUser;
    }

    return '$userLabel of $aviaryName';
  }

  // --- NEW METHOD ---
  /// Finds the top-level Aviary ID for the current user,
  /// regardless of whether they are a Guardian or a Caregiver.
  static Future<String?> findAviaryIdForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc.data()!.containsKey('partOfAviary')) {
      return userDoc.data()!['partOfAviary']; // User is a Caregiver
    } else {
      return user.uid; // User is a Guardian
    }
  }
}