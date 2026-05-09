import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD:lib/screens/admin_tabs/AdminSettingsTab.dart
import 'package:campus_news/screens/LoginScreen.dart';
import 'package:campus_news/screens/AboutScreen.dart';
import 'package:campus_news/screens/EditProfileScreen.dart';
import 'package:campus_news/screens/NotificationsScreen.dart';
import 'package:campus_news/screens/HelpScreen.dart';
=======
import 'package:campus_news/screens/login_screen.dart';
import 'package:campus_news/screens/about_screen.dart';
import 'package:campus_news/screens/edit_profile_screen.dart';
import 'package:campus_news/screens/notifications_screen.dart';
import 'package:campus_news/screens/help_screen.dart';
>>>>>>> a1589c5bf7713b355f7bb7237b33747d2b4f90eb:lib/screens/admin_tabs/admin_settings_tab.dart

class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({super.key});

  void _handleEditProfile(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
<<<<<<< HEAD:lib/screens/admin_tabs/AdminSettingsTab.dart
=======
    (context as Element).markNeedsBuild();
>>>>>>> a1589c5bf7713b355f7bb7237b33747d2b4f90eb:lib/screens/admin_tabs/admin_settings_tab.dart
  }

  void _handleNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out from Admin Panel?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.navUnselected,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Profile Section
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => _handleEditProfile(context),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withAlpha(30),
              child: Text(
                (user?.displayName ?? user?.email ?? 'A')
                    .substring(0, 1)
                    .toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            title: Text(
              user?.displayName ?? 'Admin',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            subtitle: Text(
              user?.email ?? 'Admin Account',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.navUnselected,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.navUnselected,
            ),
          ),
          const Divider(height: 32, thickness: 1, color: Colors.black12),
          const SizedBox(height: 24),

          // Settings sections
          _SettingsSection(
<<<<<<< HEAD:lib/screens/admin_tabs/AdminSettingsTab.dart
            title: 'Admin General',
=======
            title: 'General',
>>>>>>> a1589c5bf7713b355f7bb7237b33747d2b4f90eb:lib/screens/admin_tabs/admin_settings_tab.dart
            items: [
              _SettingsItem(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () => _handleEditProfile(context),
              ),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => _handleNotifications(context),
              ),
<<<<<<< HEAD:lib/screens/admin_tabs/AdminSettingsTab.dart

=======
>>>>>>> a1589c5bf7713b355f7bb7237b33747d2b4f90eb:lib/screens/admin_tabs/admin_settings_tab.dart
            ],
          ),
          const SizedBox(height: 16),

          _SettingsSection(
<<<<<<< HEAD:lib/screens/admin_tabs/AdminSettingsTab.dart
            title: 'Admin Support',
=======
            title: 'Support',
>>>>>>> a1589c5bf7713b355f7bb7237b33747d2b4f90eb:lib/screens/admin_tabs/admin_settings_tab.dart
            items: [
              _SettingsItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                label: 'About Campus News',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          _SettingsItem(
            icon: Icons.logout_rounded,
            label: 'Logout from Admin Panel',
            onTap: () => _logout(context),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Campus News Admin v1.0.0',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.navUnselected,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 8, top: 16),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryVariant, size: 24),
          ),
          title: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          trailing: trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.navUnselected,
              ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
