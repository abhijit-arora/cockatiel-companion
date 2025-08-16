import 'package:flutter/material.dart';
import 'package:cockatiel_companion/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cockatiel Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // This removes the "DEBUG" banner from the top right corner
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}