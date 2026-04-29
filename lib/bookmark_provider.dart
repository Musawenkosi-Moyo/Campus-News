import 'package:flutter/material.dart';

class NewsArticle {
  final String title;
  final String description;
  final String imageUrl;

  NewsArticle({
    required this.title, 
    required this.description, 
    required this.imageUrl
  });

  // compare articles to see if they are the same
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsArticle &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}

class BookmarkProvider extends ChangeNotifier {
  final List<NewsArticle> _items = [];

  List<NewsArticle> get items => _items;

  void toggleBookmark(NewsArticle article) {
    if (_items.contains(article)) {
      _items.remove(article);
    } else {
      _items.add(article);
    }
    notifyListeners(); 
  }

  bool isBookmarked(NewsArticle article) {
    return _items.contains(article);
  }
}