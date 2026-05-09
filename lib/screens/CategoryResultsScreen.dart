import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_news/design/colors.dart';
import 'package:campus_news/models/article.dart';
import 'package:campus_news/screens/ArticleDetailScreen.dart';

class CategoryResultsScreen extends StatelessWidget {
  final String category;

  const CategoryResultsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          category,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('articles')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong', 
                style: GoogleFonts.inter(color: colorScheme.onSurface)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryVariant));
          }

          final filteredDocs = snapshot.data!.docs
              .where((doc) => (doc.data() as Map<String, dynamic>)['isDraft'] != true)
              .toList();

          if (filteredDocs.isEmpty) {
            return _buildEmptyState(context);
          }

          final docs = snapshot.data!.docs
              .where((doc) => (doc.data() as Map<String, dynamic>)['isDraft'] != true)
              .toList();

          if (docs.isEmpty) {
            return _buildEmptyState(context);
          }

          // Sort locally to avoid Firebase composite index requirement
          docs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final tA = dataA['timestamp'] as Timestamp?;
            final tB = dataB['timestamp'] as Timestamp?;
            if (tA == null && tB == null) return 0;
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final article = Article.fromFirestore(doc);
              return _buildNewsRow(context, article);
            },
          );
        },
      ),
    );
  }

  void _openArticleRead(BuildContext context, Article article) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ArticleDetailScreen(article: article),
      ),
    );
  }

  Widget _buildNewsRow(BuildContext context, Article article) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: () => _openArticleRead(context, article),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: article.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: article.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.article_outlined, color: colorScheme.onSurfaceVariant),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.category.isNotEmpty)
                        Text(
                          article.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.primaryVariant,
                          ),
                        ),
                      if (article.category.isNotEmpty) const SizedBox(height: 4),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (article.summary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper_rounded,
            size: 64,
            color: colorScheme.onBackground.withAlpha(50),
          ),
          const SizedBox(height: 16),
          Text(
            'No news in $category yet.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: colorScheme.onBackground.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}
