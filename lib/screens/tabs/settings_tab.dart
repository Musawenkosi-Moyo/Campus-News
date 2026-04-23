import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_news/screens/login_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

 
  void _handleEditProfile(BuildContext context) async {
    
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    (context as Element).markNeedsBuild(); 
  }

  void _handleNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _handleAppearance(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Theme', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Light Mode'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: const Text('Dark Mode'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
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
          'Are you sure you want to log out?',
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
          
          InkWell(
            onTap: () => _handleEditProfile(context), 
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withAlpha(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: Text(
                      (user?.displayName ?? user?.email ?? 'U')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Student',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'No email',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.navUnselected,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.navUnselected,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Settings sections
          _SettingsSection(
            title: 'General',
            items: [
              _SettingsItem(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () => _handleEditProfile(context), // UPDATED
              ),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => _handleNotifications(context), // UPDATED
              ),
              _SettingsItem(
                icon: Icons.dark_mode_outlined,
                label: 'Appearance',
                onTap: () => _handleAppearance(context), // UPDATED
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SettingsSection(
            title: 'Support',
            items: [
              _SettingsItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () {
                  // Logic for Help
                },
              ),
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                label: 'About',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Campus News',
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(),  
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Logout
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.error.withAlpha(30),
              ),
            ),
            child: ListTile(
              onTap: () => _logout(context),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.error,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App version
          Text(
            'Campus News v1.0.0',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.navUnselected,
            ),
          ),
          const SizedBox(height: 8),
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
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.navUnselected,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withAlpha(20),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: AppColors.primary.withAlpha(15),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.onBackground,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.navUnselected,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Text(
          "Profile Settings Screen",
          style: GoogleFonts.inter(fontSize: 16),
        ),
      ),
    );
  }
}