import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Admin Dashboard!\nHere you will upload news updates.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement news upload functionality
        },
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload),
        label: const Text('Upload News'),
      ),
    );
  }
}
