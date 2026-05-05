import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About Campus News',
          style: GoogleFonts.inter(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.newspaper_rounded,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Campus News',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onBackground,
                    ),
                  ),
                  Text(
                    'v1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.navUnselected,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'What is Campus News?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Campus News is your ultimate source for everything happening around your campus. Designed specifically for students, our platform brings you real-time updates, academic news, event announcements, and much more.',
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: AppColors.onBackground.withAlpha(180),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Key Features',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.bolt_rounded,
              'Instant Updates',
              'Stay ahead with breaking news and urgent campus notices as they happen.',
            ),
            _buildFeatureItem(
              Icons.category_rounded,
              'Diverse Categories',
              'From Academics to Sports and Culture, follow the topics that matter to you.',
            ),
            _buildFeatureItem(
              Icons.bookmark_rounded,
              'Bookmarks',
              'Save your favorite articles to read them later, even without an internet connection.',
            ),
            _buildFeatureItem(
              Icons.notifications_active_rounded,
              'Smart Notifications',
              'Never miss an update with personalized alerts for new articles.',
            ),
            const SizedBox(height: 40),
            Text(
              'Our Mission',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Our mission is to foster a more connected and informed campus community. We believe that easy access to information empowers students to make the most of their university experience.',
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: AppColors.onBackground.withAlpha(180),
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: Text(
                '© 2024 Campus News Team',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.navUnselected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.navUnselected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
