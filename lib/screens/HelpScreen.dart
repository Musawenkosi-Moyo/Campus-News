import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Help & FAQ',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildFAQItem(
              context,
              'How do I receive notifications?',
              'Make sure you have enabled notifications in your device settings for Campus News. You will receive updates whenever a new article is published.',
            ),
            _buildFAQItem(
              context,
              'How can I bookmark an article?',
              'Tap the bookmark icon on any article card or detail screen to save it for later. You can find all your saved articles in the Bookmarks tab.',
            ),
            _buildFAQItem(
              context,
              'Can I contribute news?',
              'Contribution is currently limited to verified admin accounts. If you have news to share, please contact the campus media office.',
            ),
            _buildFAQItem(
              context,
              'How do I update my profile?',
              'Go to the Settings tab and tap on "Edit Profile". You can update your name and "About" section there.',
            ),
            const SizedBox(height: 32),
            Text(
              'Contact Support',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 20 : 5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildContactRow(context, Icons.email_outlined, 'support@nust.ac.zw'),
                  const Divider(height: 32),
                  _buildContactRow(context, Icons.phone_outlined, '+263 292 282842'),
                  const Divider(height: 32),
                  _buildContactRow(context, Icons.location_on_outlined, 'NUST Main Campus, Bulawayo'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: colorScheme.onSurface.withAlpha(180),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryVariant.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryVariant, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onBackground,
            ),
          ),
        ),
      ],
    );
  }
}
