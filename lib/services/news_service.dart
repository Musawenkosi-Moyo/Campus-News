import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Storage bucket in Supabase (create in Dashboard → Storage → New bucket).
/// Use a **public** bucket if you serve images via [getPublicUrl], or add
/// signed-URL policies for private buckets.
const String kSupabaseArticleBucket = 'article-images';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SupabaseClient get _supabase {
    final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    if (url.isEmpty || key.isEmpty) {
      throw Exception(
        'Add SUPABASE_URL and SUPABASE_ANON_KEY to your .env file (see Supabase '
        'Project Settings → API), then restart the app.',
      );
    }
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw Exception(
        'Supabase is not initialized. Ensure .env contains valid '
        'SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
  }

  /// Uploads an image to **Supabase Storage** and returns a public URL.
  /// Firestore still only stores this URL string on the article document.
  Future<String> uploadImage(File imageFile) async {
    final lower = imageFile.path.toLowerCase();
    final contentType = lower.endsWith('.png')
        ? 'image/png'
        : lower.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg';
    final ext = contentType.split('/').last;
    final objectPath = 'covers/news_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final client = _supabase;

    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      await client.storage.from(kSupabaseArticleBucket).uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      return client.storage
          .from(kSupabaseArticleBucket)
          .getPublicUrl(objectPath);
    } on StorageException catch (e) {
      throw Exception(
        'Supabase Storage upload failed (create bucket "$kSupabaseArticleBucket" '
        'and add storage policies — see Supabase Dashboard → Storage): ${e.message}',
      );
    } on UnsupportedError catch (e) {
      throw Exception(
        'Supabase Storage upload failed due to an unsupported file operation. '
        'Try selecting another image and ensure app storage permissions are granted. '
        'Details: $e',
      );
    } catch (e) {
      throw Exception('Supabase Storage upload failed: $e');
    }
  }

  /// Upload an image selected with [ImagePicker] (works on web and mobile).
  Future<String> uploadPickedImage(XFile imageFile) async {
    final lower = imageFile.name.toLowerCase();
    final contentType = lower.endsWith('.png')
        ? 'image/png'
        : lower.endsWith('.webp')
            ? 'image/webp'
            : lower.endsWith('.gif')
                ? 'image/gif'
                : 'image/jpeg';
    final ext = contentType.split('/').last;
    final objectPath = 'covers/news_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final client = _supabase;

    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      await client.storage.from(kSupabaseArticleBucket).uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );

      return client.storage
          .from(kSupabaseArticleBucket)
          .getPublicUrl(objectPath);
    } on StorageException catch (e) {
      throw Exception(
        'Supabase Storage upload failed (create bucket "$kSupabaseArticleBucket" '
        'and add storage policies — see Supabase Dashboard → Storage): ${e.message}',
      );
    } catch (e) {
      throw Exception('Supabase Storage upload failed: $e');
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
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
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
