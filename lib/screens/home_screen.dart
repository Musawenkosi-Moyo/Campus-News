import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus News'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: const Center(
        child: Text(
          'Welcome to Campus News!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
