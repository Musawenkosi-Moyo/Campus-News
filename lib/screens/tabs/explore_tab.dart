import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:campus_news/screens/category_results _screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final TextEditingController _searchController = TextEditingController();

  // Function to navigate to a category-specific screen
 void _navigateToCategory(BuildContext context, String categoryName) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CategoryResultsScreen(category: categoryName),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
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
                Icon(Icons.search_rounded, color: AppColors.navUnselected),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      // Trigger search logic here
                    },
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

          // 2. Categories
          Text(
            'Categories',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: [
              _CategoryCard(
                icon: Icons.school_rounded,
                label: 'Academics',
                color: const Color(0xFF4CAF50),
                onTap: () => _navigateToCategory(context, 'Academics'),
              ),
              _CategoryCard(
                icon: Icons.sports_soccer_rounded,
                label: 'Sports',
                color: const Color(0xFFFF9800),
                onTap: () => _navigateToCategory(context, 'Sports'),
              ),
              _CategoryCard(
                icon: Icons.celebration_rounded,
                label: 'Events',
                color: const Color(0xFF9C27B0),
                onTap: () => _navigateToCategory(context, 'Events'),
              ),
              _CategoryCard(
                icon: Icons.groups_rounded,
                label: 'Clubs',
                color: const Color(0xFF2196F3),
                onTap: () => _navigateToCategory(context, 'Clubs'),
              ),
            ],
          ),
          const SizedBox(height: 28),

          //Trending Topics (Connected to Firebase)
          Text(
            'Trending Topics',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 14),

          // StreamBuilder listens to Firestore articles ordered by "views"
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('articles')
                .orderBy('views', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyTrending();
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.trending_up, color: Colors.redAccent),
                    title: Text(data['title'] ?? 'No Title', 
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    subtitle: Text("${data['views']} students reading"),
                    onTap: () {
                      // Navigate to article detail
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTrending() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.trending_up_rounded, size: 48, color: AppColors.primary.withAlpha(100)),
          const SizedBox(height: 12),
          Text('No trending stories yet', style: GoogleFonts.inter(color: AppColors.navUnselected)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( 
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(40)),
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
      ),
    );
  }
}