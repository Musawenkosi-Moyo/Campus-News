import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create user in Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      // 2. Save profile to Firestore users collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 3. Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Sign up failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        message = 'Password must be at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.30;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top part with overlapping logo
            SizedBox(
              height: topHeight + 65, // Add space for the protruding half of the logo
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: topHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                  ),
                  Positioned(
                    top: topHeight - 65,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: ClipOval(
                          child: Container(
                            color: Colors.white,
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 40,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom part with form
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join us to get the latest campus updates.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: AppColors.primary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColors.primary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AppColors.primary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
