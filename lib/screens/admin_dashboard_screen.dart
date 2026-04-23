import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_news/design/colors.dart'; // Using your custom colors
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  // Firebase Logout Logic integrated from your second snippet
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          // 1. Sidebar / Navigation Rail
          NavigationRail(
            backgroundColor: Colors.white,
            elevation: 5,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedIconTheme: IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.article), label: Text('Articles')),
              NavigationRailDestination(icon: Icon(Icons.star), label: Text('Featured')),
              NavigationRailDestination(icon: Icon(Icons.edit_note), label: Text('Drafts')),
              NavigationRailDestination(icon: Icon(Icons.upload), label: Text('Upload')),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
            ],
          ),

          // 2. Main Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Integrated Header with Logout Logic
                _buildHeader(context),
                
                // Statistics Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GridView.count(
                      crossAxisCount: 3, 
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.5, 
                      children: const [
                        StatCard(title: "TOTAL USERS", value: "4127"),
                        StatCard(title: "TOTAL ARTICLES", value: "20"),
                        StatCard(title: "FEATURED ITEMS", value: "5"),
                        StatCard(title: "TOTAL NOTIFICATIONS", value: "21"),
                        StatCard(title: "TOTAL CATEGORIES", value: "9"),
                        StatCard(title: "TOTAL DRAFTS", value: "1"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button from your second snippet
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement news upload functionality
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.upload),
        label: const Text('Upload News'),
      ),
    );
  }

  // Header Widget using your AppColors and Firebase Logout
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Campus News - Admin Panel",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text("Logout"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 15),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              )
            ],
          )
        ],
      ),
    );
  }
}

// Reusable Stat Card Widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 3,
            width: 30,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        ],
      ),
    );
  }
}