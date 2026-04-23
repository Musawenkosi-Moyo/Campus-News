import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads an image to Firebase Storage and returns the download URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = 'news_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('news_images').child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Saves article data to Firestore
  Future<bool> uploadArticle({
    required String title,
    required String category,
    required String content,
    required String? imageUrl,
    bool isDraft = false,
  }) async {
    try {
      final user = _auth.currentUser;
      await _firestore.collection('articles').add({
        'title': title,
        'category': category,
        'content': content,
        'imageUrl': imageUrl,
        'authorId': user?.uid,
        'authorEmail': user?.email,
        'timestamp': FieldValue.serverTimestamp(),
        'isDraft': isDraft,
        'views': 0,
      });
      return true;
    } catch (e) {
      print('Error uploading article: $e');
      return false;
    }
  }
}
