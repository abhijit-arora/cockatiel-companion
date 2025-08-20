import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Sign Up'),
      ),
      body: SingleChildScrollView( // <-- Add ScrollView for smaller screens
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // We don't need mainAxisAlignment here anymore
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60), // Add space from the top

              // --- NEW BRANDING SECTION ---
              Image.asset(
                'assets/images/logo.png',
                height: 150, // A bit larger than the AppBar version
              ),
              const SizedBox(height: 16),
              Text(
                'FlockWell',
                textAlign: TextAlign.center,
                // Use the beautiful headline style from our theme
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
        
              // Email Text Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),

              // Spacer
              const SizedBox(height: 16.0),

              // Password Text Field
              TextField(
                controller: _passwordController,
                obscureText: true, // This hides the password characters
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              // Spacer
              const SizedBox(height: 24.0),

              // Login Button
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Login'),
              ),

              // Spacer
              const SizedBox(height: 8.0),

              // Sign Up Button
              OutlinedButton( // <-- Change to OutlinedButton
                onPressed: _signUp,
                // No style is needed! It will automatically use our theme.
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    try {
      // Get the email and password from the controllers
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Use Firebase Auth to create a new user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optional: print a success message to the console
      print('Successfully signed up: ${userCredential.user?.email}');

    } on FirebaseAuthException catch (e) {
      // Handle potential errors, like if the email is already in use
      print('Failed to sign up: ${e.message}');
      // We can show a dialog to the user here later
    }
  }

  Future<void> _signIn() async {
    try {
      // Get the email and password from the controllers
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Use Firebase Auth to sign in an existing user
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optional: print a success message to the console
      print('Successfully signed in: ${userCredential.user?.email}');

    } on FirebaseAuthException catch (e) {
      // Handle potential errors, like wrong password or user not found
      print('Failed to sign in: ${e.message}');
      // We can show a dialog to the user here later
    }
  }
}