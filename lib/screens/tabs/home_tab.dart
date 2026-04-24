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
// 🧪 MOCK DATA — remove when Firestore access is granted
// ─────────────────────────────────────────────
final List<Article> _mockArticles = [
  Article(
    id: '1',
    title: 'Campus Hackathon 2026 draws record 400 participants',
    summary: 'Students build innovative apps over 48 hours of non-stop coding',
    imageUrl: '',
    category: 'Events',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isFeatured: true,
  ),
  Article(
    id: '2',
    title: 'Basketball team qualifies for national championship finals',
    summary: 'Coach praises team resilience after a tough semifinal win',
    imageUrl: '',
    category: 'Sports',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    isFeatured: false,
  ),
  Article(
    id: '3',
    title: 'New AI research lab opens for student use on campus',
    summary: 'Faculty and students gain access to cutting-edge GPU clusters',
    imageUrl: '',
    category: 'Academic',
    timestamp: DateTime.now().subtract(const Duration(hours: 10)),
    isFeatured: false,
  ),
  Article(
    id: '4',
    title: 'Student café introduces all-night study hours next week',
    summary: 'Popular spot stays open until 2am during exam season',
    imageUrl: '',
    category: 'Campus Life',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isFeatured: false,
  ),
  Article(
    id: '5',
    title: 'Engineering faculty wins prestigious national research grant',
    summary: 'R2.4 million awarded for renewable energy infrastructure project',
    imageUrl: '',
    category: 'Academic',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isFeatured: false,
  ),
  Article(
    id: '6',
    title: 'SRC elections open next Monday — here is how to vote',
    summary: 'Six candidates contesting for four available positions this term',
    imageUrl: '',
    category: 'Campus Life',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    isFeatured: false,
  ),
];

const String _mockBreakingTitle =
    'Student union announces new campus Wi-Fi rollout starting Monday';

// ─────────────────────────────────────────────
// 🏠 HOME TAB
// ─────────────────────────────────────────────
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),

          // ── Breaking News Banner ─────────────────
          const SliverToBoxAdapter(
            child: _BreakingNewsBanner(),
          ),

          // ── Featured Article ─────────────────────
          // 🔁 SWAP: replace with StreamBuilder when Firestore is ready
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _FeaturedCard(article: _mockArticles.first),
            ),
          ),

          // ── Category Filter Chips ────────────────
          SliverToBoxAdapter(
            child: _CategoryChips(),
          ),

          // ── Section Header ───────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Updates',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Articles List ────────────────────────
          // 🔁 SWAP: replace with StreamBuilder when Firestore is ready
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _AnimatedArticleCard(
                  article: _mockArticles[index],
                  index: index,
                ),
                childCount: _mockArticles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 📰 BREAKING NEWS BANNER
// ─────────────────────────────────────────────
class _BreakingNewsBanner extends StatelessWidget {
  const _BreakingNewsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB300), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'BREAKING',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 🔁 SWAP: replace with StreamBuilder when Firestore is ready
          Expanded(
            child: Text(
              _mockBreakingTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7A5500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 🏷️ CATEGORY CHIPS
// ─────────────────────────────────────────────
class _CategoryChips extends StatefulWidget {
  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  int _selected = 0;
  final List<String> _categories = [
    'All',
    'Events',
    'Sports',
    'Academic',
    'Campus Life',
    'Tech',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selected == index;
          return GestureDetector(
            onTap: () => setState(() => _selected = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withAlpha(30),
                ),
              ),
              child: Text(
                _categories[index],
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? Colors.white : AppColors.navUnselected,
                ),
              ),
            ),
          );
        },
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
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(60),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
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
                      placeholder: (context, url) => Container(
                        color: AppColors.primary.withAlpha(30),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A3A6B), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A3A6B), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(180),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _CategoryBadge(label: article.category),
                        const SizedBox(width: 8),
                        const _CategoryBadge(
                            label: '🔥 Featured', featured: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          article.timeAgo,
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 🏷️ CATEGORY BADGE
// ─────────────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  final String label;
  final bool featured;

  const _CategoryBadge({required this.label, this.featured = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: featured
            ? AppColors.primary.withAlpha(200)
            : Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(40), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 📄 ARTICLE CARD (animated wrapper)
// ─────────────────────────────────────────────
class _AnimatedArticleCard extends StatefulWidget {
  final Article article;
  final int index;

  const _AnimatedArticleCard({required this.article, required this.index});

  @override
  State<_AnimatedArticleCard> createState() => _AnimatedArticleCardState();
}

class _AnimatedArticleCardState extends State<_AnimatedArticleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ArticleCard(article: widget.article),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 📰 ARTICLE CARD
// ─────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withAlpha(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: article.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: article.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                              color: AppColors.primary.withAlpha(20)),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.primary.withAlpha(20),
                            child: Icon(Icons.image_outlined,
                                color: AppColors.primary.withAlpha(80)),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withAlpha(20),
                          child: Icon(Icons.article_rounded,
                              color: AppColors.primary.withAlpha(80)),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              article.category.toUpperCase(),
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            article.timeAgo,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.navUnselected,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBackground,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.navUnselected,
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
    );
  }
}

// ─────────────────────────────────────────────
// 💀 SHIMMER PLACEHOLDERS (kept for when Firestore is ready)
// ─────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmerAnim =
        CurvedAnimation(parent: _shimmerController, curve: Curves.linear);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _shimmerAnim.value - 0.3, 0),
              end: Alignment(-1 + 2 * _shimmerAnim.value + 0.3, 0),
              colors: [
                AppColors.surface,
                AppColors.primary.withAlpha(15),
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeaturedShimmer extends StatelessWidget {
  const _FeaturedShimmer();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: _ShimmerBox(
        width: double.infinity,
        height: 220,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ArticleShimmer extends StatelessWidget {
  const _ArticleShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _ShimmerBox(
            width: 100,
            height: 100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShimmerBox(width: 80, height: 12),
                  _ShimmerBox(width: double.infinity, height: 14),
                  _ShimmerBox(width: 160, height: 14),
                  _ShimmerBox(width: 100, height: 11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}