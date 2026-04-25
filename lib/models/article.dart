import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String category;
  final DateTime timestamp;
  final bool isFeatured;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.timestamp,
    required this.isFeatured,
  });

  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawContent = (data['content'] ?? '').toString();
    final rawSummary = (data['summary'] ?? '').toString();
    final summary = rawSummary.isNotEmpty
        ? rawSummary
        : (rawContent.length > 120
            ? '${rawContent.substring(0, 120)}…'
            : rawContent);

    final ts = data['timestamp'];
    final DateTime when = ts is Timestamp
        ? ts.toDate()
        : DateTime.now();

    return Article(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      summary: summary,
      content: rawContent,
      imageUrl: data['imageUrl']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      timestamp: when,
      isFeatured: data['isFeatured'] == true,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
