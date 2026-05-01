import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_news/design/colors.dart';
import 'package:campus_news/models/article.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen read view for an [Article] from the home feed.
class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  String get _body {
    final c = article.content.trim();
    if (c.isNotEmpty) return c;
    return article.summary.trim();
  }

  Future<void> _openPdf(BuildContext context, LaunchMode mode) async {
    final pdfUrl = article.pdfUrl.trim();
    if (pdfUrl.isEmpty) return;

    final uri = Uri.tryParse(pdfUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This PDF link is invalid.')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: mode);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the PDF right now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (article.imageUrl.isNotEmpty)
            SliverAppBar(
              pinned: true,
              expandedHeight: 280,
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.onBackground, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.onBackground, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.category.isNotEmpty)
                    Text(
                      article.category.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: AppColors.primary,
                      ),
                    ),
                  if (article.category.isNotEmpty) const SizedBox(height: 10),
                  Text(
                    article.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.timeAgo,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.navUnselected,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (article.pdfUrl.trim().isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attached PDF',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onBackground,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Open the full article as a PDF or download it to your device.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.navUnselected,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _openPdf(
                                    context,
                                    LaunchMode.platformDefault,
                                  ),
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  label: const Text('Open PDF'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _openPdf(
                                    context,
                                    LaunchMode.externalApplication,
                                  ),
                                  icon: const Icon(Icons.download_rounded),
                                  label: const Text('Download'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    _body.isNotEmpty ? _body : 'No article text yet.',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.onBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
