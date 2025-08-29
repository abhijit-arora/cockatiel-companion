import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/services/auth_service.dart';
import 'package:cockatiel_companion/screens/main_screen.dart';
import 'screens/auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  
  @override
  Widget build(BuildContext context) {
    final authService = AuthService(); // <-- Create an instance
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // If the snapshot has data, it means the user is logged in
        if (snapshot.hasData) {
          // Show the main app screen
          return const MainScreen();
        } else {
          // Otherwise, the user is not logged in, show the auth screen
          return const AuthScreen();
        }
      },
    );
  }
}