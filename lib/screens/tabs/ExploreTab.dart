import 'package:flutter/material.dart';
import 'package:campus_news/design/colors.dart';
import 'package:campus_news/screens/CategoryResultsScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryVariant.withAlpha(100),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.navUnselected),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    style: TextStyle(color: colorScheme.onBackground),
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
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),

          if (_searchQuery.isEmpty) ...[
            Column(
              children: [
                _CategoryListItem(
                  icon: Icons.school_rounded,
                  label: 'Academics',
                  color: const Color(0xFF4CAF50),
                  onTap: () => _navigateToCategory(context, 'Academics'),
                ),
                _CategoryListItem(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Sports',
                  color: const Color(0xFFFF9800),
                  onTap: () => _navigateToCategory(context, 'Sports'),
                ),
                _CategoryListItem(
                  icon: Icons.celebration_rounded,
                  label: 'Events',
                  color: const Color(0xFF9C27B0),
                  onTap: () => _navigateToCategory(context, 'Events'),
                ),
                _CategoryListItem(
                  icon: Icons.groups_rounded,
                  label: 'Clubs',
                  color: const Color(0xFF2196F3),
                  onTap: () => _navigateToCategory(context, 'Clubs'),
                ),
                _CategoryListItem(
                  icon: Icons.health_and_safety_rounded,
                  label: 'Health',
                  color: Colors.red,
                  onTap: () => _navigateToCategory(context, 'Health'),
                ),
                _CategoryListItem(
                  icon: Icons.computer_rounded,
                  label: 'Tech',
                  color: Colors.teal,
                  onTap: () => _navigateToCategory(context, 'Tech'),
                ),
                _CategoryListItem(
                  icon: Icons.palette_rounded,
                  label: 'Culture',
                  color: Colors.pink,
                  onTap: () => _navigateToCategory(context, 'Culture'),
                ),
                _CategoryListItem(
                  icon: Icons.public_rounded,
                  label: 'General',
                  color: Colors.blueGrey,
                  onTap: () => _navigateToCategory(context, 'General'),
                ),
                _CategoryListItem(
                  icon: Icons.campaign_rounded,
                  label: 'Notices',
                  color: Colors.deepOrange,
                  onTap: () => _navigateToCategory(context, 'Notices'),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Text(
              'Trending News',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 14),

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
                
                final trendingDocs = snapshot.hasData
                  ? snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['isDraft'] != true).toList()
                  : [];

                if (trendingDocs.isEmpty) {
                  return _buildEmptyTrending();
                }

                return Column(
                  children: trendingDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.trending_up, color: Colors.redAccent),
                      title: Text(data['title'] ?? 'No Title', 
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onBackground,
                        )),
                      subtitle: Text("${data['views']} students reading",
                        style: TextStyle(color: colorScheme.onBackground.withAlpha(150))),
                      onTap: () {
                        // Navigate to article detail
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ] else ...[
            Text(
              'Search Results',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 14),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('articles')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final allDocs = snapshot.data?.docs ?? [];
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final isDraft = data['isDraft'] == true;
                  return title.contains(_searchQuery.toLowerCase()) && !isDraft;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('No news found for "$_searchQuery"', 
                        style: GoogleFonts.inter(color: AppColors.navUnselected)),
                    ),
                  );
                }

                return Column(
                  children: filteredDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.article_outlined, color: AppColors.primaryVariant),
                      title: Text(data['title'] ?? 'No Title', 
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onBackground,
                        )),
                      subtitle: Text(data['category'] ?? '',
                        style: TextStyle(color: colorScheme.onBackground.withAlpha(150))),
                      onTap: () {
                        // Navigate to article detail
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
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

class _CategoryListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryListItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
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
              color: colorScheme.onBackground,
            ),
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }
}