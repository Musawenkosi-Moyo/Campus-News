import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:campus_news/models/article.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkProvider extends ChangeNotifier {
  static const String _storageKey = 'bookmarked_articles_v1';
  final List<Article> _items = [];

  List<Article> get items => List.unmodifiable(_items);

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    _items
      ..clear()
      ..addAll(
        decoded
            .whereType<Map>()
            .map((entry) => _articleFromJson(Map<String, dynamic>.from(entry))),
      );
    notifyListeners();
  }

  Future<void> toggleBookmark(Article article) async {
    if (isBookmarked(article)) {
      _items.removeWhere((item) => item.id == article.id);
    } else {
      _items.add(article);
    }
    await _saveBookmarks();
    notifyListeners();
  }

  bool isBookmarked(Article article) {
    return _items.any((item) => item.id == article.id);
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _items.map(_articleToJson).toList(growable: false);
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  Map<String, dynamic> _articleToJson(Article article) {
    return {
      'id': article.id,
      'title': article.title,
      'summary': article.summary,
      'content': article.content,
      'imageUrl': article.imageUrl,
      'pdfUrl': article.pdfUrl,
      'category': article.category,
      'timestamp': article.timestamp.toIso8601String(),
      'isFeatured': article.isFeatured,
    };
  }

  Article _articleFromJson(Map<String, dynamic> data) {
    return Article(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      summary: data['summary']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      pdfUrl: data['pdfUrl']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(data['timestamp']?.toString() ?? '') ?? DateTime.now(),
      isFeatured: data['isFeatured'] == true,
    );
  }
}

final BookmarkProvider bookmarkProvider = BookmarkProvider();