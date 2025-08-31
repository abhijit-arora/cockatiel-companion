// lib/features/authentication/screens/auth_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cockatiel_companion/features/authentication/services/auth_service.dart';
import 'package:cockatiel_companion/core/constants.dart';

enum AuthMode { login, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- LOGIC FUNCTIONS ---

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_authMode == AuthMode.login) {
        await _authService.signInWithEmail(email, password);
      } else {
        await _authService.signUpWithEmail(email, password);
      }
      // On success, the AuthGate will handle navigation automatically.
    } on FirebaseAuthException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.message ?? AppStrings.genericError)),
      );
    }
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.passwordResetSuccess)),
      );
    } on FirebaseAuthException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.message ?? AppStrings.genericError)),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ScreenTitles.resetPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.resetPasswordInstructions),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: Labels.email),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(ButtonLabels.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text(ButtonLabels.sendLink),
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                _sendPasswordResetEmail(emailController.text.trim());
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _authService.signInWithGoogle();
      // AuthGate handles navigation
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${AppStrings.failedToSignInWithGoogle}: $e')),
      );
    }
  }

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_authMode == AuthMode.login ? ScreenTitles.login : ScreenTitles.signUp),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Image.asset(AssetPaths.logo, height: 150),
                const SizedBox(height: 16),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: Labels.email, border: OutlineInputBorder()),
                  validator: (value) => (value == null || !value.contains('@')) ? AppStrings.emailValidation : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: Labels.password, border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.length < 6) ? AppStrings.passwordLengthValidation : null,
                ),
                if (_authMode == AuthMode.signUp) ...[
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: Labels.confirmPassword, border: OutlineInputBorder()),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return AppStrings.passwordMismatchValidation;
                      }
                      return null;
                    },
                  ),
                ],
                if (_authMode == AuthMode.login)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text(Labels.forgotPassword),
                    ),
                  ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_authMode == AuthMode.login ? ButtonLabels.login : ButtonLabels.createAccount),
                ),
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _authMode = _authMode == AuthMode.login ? AuthMode.signUp : AuthMode.login;
                    });
                  },
                  child: Text(_authMode == AuthMode.login
                      ? AppStrings.dontHaveAccount
                      : AppStrings.alreadyHaveAccount),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(AppStrings.orSeparator),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Image.asset(AssetPaths.googleLogo, height: 24.0),
                  label: const Text(ButtonLabels.signInWithGoogle),
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
      ),
    );
  }
}