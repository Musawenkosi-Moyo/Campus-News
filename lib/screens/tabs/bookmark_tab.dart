import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_news/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_news/bookmark_provider.dart'; // Ensure this path is correct

class BookmarkTab extends StatelessWidget {
  const BookmarkTab({super.key});

  @override
  Widget build(BuildContext context) {
    // This listens to the Provider for any changes
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarkedArticles = bookmarkProvider.items;

    return Scaffold(
      
      body: bookmarkedArticles.isEmpty
          ? _buildEmptyState()
          : _buildBookmarkList(context, bookmarkedArticles),
    );
  }

  // The listview which displays when there are articles
  Widget _buildBookmarkList(BuildContext context, List<NewsArticle> articles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Article Image Preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    article.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Article Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Functional Bookmark Button
                IconButton(
                  icon: const Icon(Icons.bookmark, color: AppColors.primary),
                  onPressed: () {
                    // Logic to remove from bookmarks
                    Provider.of<BookmarkProvider>(context, listen: false)
                        .toggleBookmark(article);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Removed from Bookmarks")),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // THE EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_rounded,
                size: 48,
                color: AppColors.primary.withAlpha(180),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No Bookmarks Yet',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Articles you save will appear here.\nTap the bookmark icon on any article to save it for later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.navUnselected,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () {
              },
              icon: const Icon(Icons.explore_rounded),
              label: Text(
                'Explore Articles',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}