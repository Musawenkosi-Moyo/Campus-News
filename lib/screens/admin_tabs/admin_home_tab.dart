import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_news/design/colors.dart';
import 'package:campus_news/models/article.dart';
import 'package:campus_news/screens/admin_tabs/admin_edit_article_screen.dart';
import 'package:campus_news/screens/article_detail_screen.dart';

void _openAdminArticleRead(BuildContext context, Article article) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ArticleDetailScreen(
        article: article,
        showEditButton: true,
        onEdit: () async {
          final updated = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => AdminEditArticleScreen(article: article),
            ),
          );
          if (updated == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Article refreshed with updates.')),
            );
          }
        },
        onDelete: () async {
          try {
            await FirebaseFirestore.instance
                .collection('articles')
                .doc(article.id)
                .delete();
            if (!context.mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Article deleted successfully.')),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not delete article: $e')),
            );
          }
        },
      ),
    ),
  );
}

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  PageController? _headlineController;
  Timer? _headlineTimer;
  int _headlineIndex = 0;
  int _headlineCount = 0;

  @override
  void initState() {
    super.initState();
    _headlineController = PageController(viewportFraction: 1);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _startHeadlineRotation();
  }

  @override
  void dispose() {
    _headlineTimer?.cancel();
    _headlineController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startHeadlineRotation() {
    _headlineTimer?.cancel();
    _headlineTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      final controller = _headlineController;
      if (controller == null || !controller.hasClients || _headlineCount <= 1) {
        return;
      }
      final nextPage = _headlineIndex >= _headlineCount - 1
          ? 0
          : _headlineIndex + 1;
      controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  Stream<List<Article>> getArticles() {
    return FirebaseFirestore.instance
        .collection('articles')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Article.fromFirestore(doc)).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: StreamBuilder<List<Article>>(
              stream: getArticles(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: SizedBox(
                          height: 220,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ...List.generate(
                        5,
                        (_) => const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                          child: _ArticleShimmer(),
                        ),
                      ),
                    ],
                  );
                }

                final articles = snapshot.data!;

                if (articles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No articles found"),
                  );
                }

                final headlines = articles.take(3).toList();
                _headlineCount = headlines.length;
                if (_headlineIndex >= _headlineCount && _headlineCount > 0) {
                  _headlineIndex = 0;
                }
                _headlineController ??= PageController(viewportFraction: 1);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        'Headlines',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: SizedBox(
                        height: 220,
                        child: PageView.builder(
                          controller: _headlineController,
                          itemCount: headlines.isEmpty ? 0 : headlines.length,
                          onPageChanged: (index) {
                            setState(() {
                              _headlineIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final article = headlines[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _FeaturedCard(article: article),
                            );
                          },
                        ),
                      ),
                    ),
                    if (headlines.length > 1)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            headlines.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == _headlineIndex ? 18 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: index == _headlineIndex
                                    ? AppColors.primary
                                    : AppColors.primary.withAlpha(70),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Text(
                        'Recent Updates',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                    ),
                    ListView.builder(
                      itemCount: articles.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemBuilder: (context, index) {
                        return _AnimatedArticleCard(
                          article: articles[index],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Article article;

  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openAdminArticleRead(context, article),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blueGrey.shade400,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (article.imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                  )
                else
                  const SizedBox.expand(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (article.category.isNotEmpty)
                          Text(
                            article.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.05,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        if (article.category.isNotEmpty)
                          const SizedBox(height: 6),
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedArticleCard extends StatelessWidget {
  final Article article;

  const _AnimatedArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return _ArticleCard(article: article);
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => _openAdminArticleRead(context, article),
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
                        : ColoredBox(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.article_outlined),
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
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      if (article.category.isNotEmpty) const SizedBox(height: 4),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          color: AppColors.onBackground,
                        ),
                      ),
                      if (article.summary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: Colors.black54,
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
          color: AppColors.primary.withAlpha(30),
        ),
      ],
    );
  }
}

class _ArticleShimmer extends StatelessWidget {
  const _ArticleShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.grey.shade300,
    );
  }
}
