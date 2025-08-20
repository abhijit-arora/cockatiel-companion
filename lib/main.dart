import 'package:flutter/material.dart';
import 'package:cockatiel_companion/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlockWell',
      theme: ThemeData(
        useMaterial3: true,

        // 1. COLOR SCHEME
        // We'll keep our seed color, it's a great base.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5BB2DE), // Our primary soft blue
          // Optional: Define a secondary color for accents
          secondary: const Color(0xFFFDE68A), // A soft sunny yellow from the logo's cheek
        ),

        // 2. APP BAR THEME
        // This will apply to all AppBars in the app
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5BB2DE), // Match our primary color
          foregroundColor: Colors.white, // Make icons and title text white
          elevation: 2.0,
        ),

        // 3. TEXT THEME
        // Define default styles for headlines, titles, and body text
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
          bodyMedium: TextStyle(fontSize: 16.0),
          labelLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0), // For button text
        ),

        // 4. ELEVATED BUTTON THEME
        // Define a consistent style for all major action buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5BB2DE), // Primary button color
            foregroundColor: Colors.white, // Button text color
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),
        
        // 5. CARD THEME
        // Define a default style for all Cards
        cardTheme: CardThemeData( // <-- CORRECTED CLASS NAME
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        ),

        // 6. FLOATING ACTION BUTTON THEME
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFDE68A), // Use our sunny yellow for the FAB
          foregroundColor: Colors.black,
        ),
      ),
      // This removes the "DEBUG" banner from the top right corner
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}