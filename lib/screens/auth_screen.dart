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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              onPressed: () {
                // We will add login logic here later
              },
              child: const Text('Login'),
            ),

            // Spacer
            const SizedBox(height: 8.0),

            // Sign Up Button
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
              ),
              child: const Text('Sign Up'),
            ),
          ],
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
}