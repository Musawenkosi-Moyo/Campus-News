import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withAlpha(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.navUnselected,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search campus news...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.navUnselected,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Categories header
          Text(
            'Categories',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),

          // Category grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: const [
              _CategoryCard(
                icon: Icons.school_rounded,
                label: 'Academics',
                color: Color(0xFF4CAF50),
              ),
              _CategoryCard(
                icon: Icons.sports_soccer_rounded,
                label: 'Sports',
                color: Color(0xFFFF9800),
              ),
              _CategoryCard(
                icon: Icons.celebration_rounded,
                label: 'Events',
                color: Color(0xFF9C27B0),
              ),
              _CategoryCard(
                icon: Icons.groups_rounded,
                label: 'Clubs',
                color: Color(0xFF2196F3),
              ),
              _CategoryCard(
                icon: Icons.science_rounded,
                label: 'Research',
                color: Color(0xFFE91E63),
              ),
              _CategoryCard(
                icon: Icons.work_rounded,
                label: 'Careers',
                color: Color(0xFF009688),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Trending section
          Text(
            'Trending Topics',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 14),

          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.trending_up_rounded,
                  size: 48,
                  color: AppColors.primary.withAlpha(100),
                ),
                const SizedBox(height: 12),
                Text(
                  'Trending stories will appear here',
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

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withAlpha(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
