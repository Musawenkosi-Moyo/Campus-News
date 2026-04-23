import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_tabs/admin_home_tab.dart';
import 'admin_tabs/admin_category_tab.dart';
import 'admin_tabs/admin_upload_tab.dart';
import 'admin_tabs/admin_draft_tab.dart';
import 'admin_tabs/admin_settings_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Admin Dashboard',
    'Categories',
    'Upload News',
    'Drafts',
    'Admin Settings',
  ];

  static const List<Widget> _tabs = [
    AdminHomeTab(),
    AdminCategoryTab(),
    AdminUploadTab(),
    AdminDraftTab(),
    AdminSettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBarBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.navUnselected,
              selectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined, size: 26),
                  activeIcon: Icon(Icons.dashboard_rounded, size: 26),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined, size: 26),
                  activeIcon: Icon(Icons.category_rounded, size: 26),
                  label: 'Category',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline_rounded, size: 32),
                  activeIcon: Icon(Icons.add_circle_rounded, size: 32),
                  label: 'Upload',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit_note_outlined, size: 26),
                  activeIcon: Icon(Icons.edit_note_rounded, size: 26),
                  label: 'Draft',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined, size: 26),
                  activeIcon: Icon(Icons.settings_rounded, size: 26),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}