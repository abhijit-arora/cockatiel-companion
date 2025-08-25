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
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Login'),
              ),
              const SizedBox(height: 8.0),
              OutlinedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Image.asset('assets/images/google_logo.png', height: 24.0), // We will add this asset
                label: const Text('Sign in with Google'),
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuthAction(Future<UserCredential> Function() authFunction, String successMessage, String errorMessage) async {
    // Validate the form fields first
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }
    
    try {
      await authFunction();
      print(successMessage);
    } on FirebaseAuthException catch (e) {
      print('$errorMessage: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An unknown error occurred.')),
        );
      }
    }
  }

  void _signUp() {
    _handleAuthAction(
      () => FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
      'Successfully signed up!',
      'Failed to sign up',
    );
  }

  void _signIn() {
    _handleAuthAction(
      () => FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
      'Successfully signed in!',
      'Failed to sign in',
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      // 1. Create an instance of the Google provider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      // 2. Use Firebase to trigger the sign-in flow
      // This will automatically handle the pop-up and user selection.
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);

      // 3. The user is now signed in to Firebase.
      // The AuthGate will handle navigation automatically.
      print('Successfully signed in with Google: ${userCredential.user?.email}');

    } catch (e) {
      print('Error during Google Sign In: $e');
      // Guard against context errors if the widget is no longer visible
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in with Google: $e')),
        );
      }
    }
  }
}