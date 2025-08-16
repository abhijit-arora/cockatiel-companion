import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

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
              onPressed: () {
                // We will add sign up logic here later
              },
              style: ElevatedButton.styleFrom(
                // A slightly different style to distinguish it
                backgroundColor: Colors.grey.shade200,
              ),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}