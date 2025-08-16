import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the Firebase auth state changes stream
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has data, it means the user is logged in
        if (snapshot.hasData) {
          // Show the main app screen
          return const HomePage();
        } else {
          // Otherwise, the user is not logged in, show the auth screen
          return const AuthScreen();
        }
      },
    );
  }
}