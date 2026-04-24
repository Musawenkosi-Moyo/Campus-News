import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_news/design/colors.dart';


// ─────────────────────────────────────────────
// 📦 ARTICLE MODEL
// ─────────────────────────────────────────────
class Article {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String category;
  final DateTime timestamp;
  final bool isFeatured;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.category,
    required this.timestamp,
    required this.isFeatured,
  });

  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Article(
      id: doc.id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}


// ─────────────────────────────────────────────
// 🏠 HOME TAB
// ─────────────────────────────────────────────
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with SingleTickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning ☀️";
    if (hour < 18) return "Good Afternoon 🌤";
    return "Good Evening 🌙";
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // 🔥 FIRESTORE STREAM
  // ─────────────────────────────────────────────
  Stream<List<Article>> getArticles() {
    return FirebaseFirestore.instance
        .collection('articles')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Article.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── APP BAR ─────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  Text(
                    'Stay updated with campus stories',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.navUnselected,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.onBackground,
              )
            ],
          ),

          // ── BREAKING NEWS (still static for now) ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB300)),
              ),
              child: Text(
                "Breaking news will come from Firestore later",
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
            ),
          ),

          // ── FEATURED ARTICLE ─────────────────────
          SliverToBoxAdapter(
            child: StreamBuilder<List<Article>>(
              stream: getArticles(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 220);
                }

                final articles = snapshot.data!;
                if (articles.isEmpty) return const SizedBox();

                final featured = articles.firstWhere(
                  (a) => a.isFeatured,
                  orElse: () => articles.first,
                );

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _FeaturedCard(article: featured),
                );
              },
            ),
          ),

          // ── CATEGORY CHIPS ───────────────────────
          SliverToBoxAdapter(child: _CategoryChips()),

          // ── HEADER ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Recent Updates',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
            ),
          ),

          // ── ARTICLES LIST ────────────────────────
          SliverToBoxAdapter(
            child: StreamBuilder<List<Article>>(
              stream: getArticles(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    children: List.generate(
                      5,
                      (_) => const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: _ArticleShimmer(),
                      ),
                    ),
                  );
                }

                final articles = snapshot.data!;

                if (articles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No articles found"),
                  );
                }

                return ListView.builder(
                  itemCount: articles.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  itemBuilder: (context, index) {
                    return _AnimatedArticleCard(
                      article: articles[index],
                      index: index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
// 🌟 FEATURED CARD
// ─────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Article article;

  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            article.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.blueGrey),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                article.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
// 📰 ARTICLE CARD + ANIMATION
// ─────────────────────────────────────────────
class _AnimatedArticleCard extends StatelessWidget {
  final Article article;
  final int index;

  const _AnimatedArticleCard({
    required this.article,
    required this.index,
  });

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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade300,
            child: article.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.article),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(article.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────
// 🏷 CATEGORY CHIPS (UI ONLY)
// ─────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        children: const [
          _Chip("All"),
          _Chip("Events"),
          _Chip("Sports"),
          _Chip("Academic"),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }
}


// ─────────────────────────────────────────────
// SHIMMERS (simple placeholders)
// ─────────────────────────────────────────────
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