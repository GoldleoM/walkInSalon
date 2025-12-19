import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;
import 'package:walkinsalonapp/models/post_model.dart';
import 'package:walkinsalonapp/models/comment_model.dart';
import 'package:walkinsalonapp/models/salon_model.dart'; // Assuming we might need this or just string ref
// import 'package:walkinsalonapp/services/image_upload_service.dart'; // Using Supabase directly

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch posts ordered by creation date
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PostModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // --- Comments ---

  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> addComment(String postId, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Fetch user name (from Users collection)
    // Could check role to determine if we look in 'users' or 'businesses' but
    // usually common user profile data is sufficient. Assuming 'users' for now.
    // If user is a business commenting, it might be in 'businesses'.
    // Simple fallback strategy:

    String userName = 'User';

    // Try customer profile
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      userName = '${data?['firstName'] ?? ''} ${data?['lastName'] ?? ''}'
          .trim();
      if (userName.isEmpty) userName = 'User';
    } else {
      // Try business profile
      final businessDoc = await _firestore
          .collection('businesses')
          .doc(user.uid)
          .get();
      if (businessDoc.exists) {
        userName = businessDoc.data()?['salonName'] ?? 'Business';
      }
    }

    final comment = CommentModel(
      id: '',
      postId: postId,
      userId: user.uid,
      userName: userName,
      text: text,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(comment.toMap());
  }

  // Like a post
  Future<void> likePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _firestore.collection('posts').doc(postId);

    // Use a transaction to safely update likes
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;

      final List<String> likes = List<String>.from(
        snapshot.data()?['likes'] ?? [],
      );
      if (likes.contains(user.uid)) {
        likes.remove(user.uid);
      } else {
        likes.add(user.uid);
      }

      transaction.update(postRef, {'likes': likes});
    });
  }

  // Share a post
  Future<void> sharePost(PostModel post) async {
    // Sharing the salon link or deep link would be ideal,
    // for now we share the description and image URL or just a text.
    await Share.share(
      'Check out this post from ${post.salonName}!\n\n${post.description}\n\nSee more on WalkInSalon.',
      subject: 'Post from ${post.salonName}',
    );
  }

  // Compression helper
  Future<File?> _compressImage(File file) async {
    final int maxSize = 300 * 1024; // 300KB
    int quality = 85;

    // Create new path for compressed file
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = p.join(dir.path, '${const Uuid().v4()}.jpg');

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: 1080,
      minHeight: 1080,
    );

    if (result == null) return null;

    // Check size loop
    int size = await result.length();
    while (size > maxSize && quality > 10) {
      quality -= 10;
      result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1080,
        minHeight: 1080,
      );
      if (result != null) {
        size = await result.length();
      }
    }

    return result != null ? File(result.path) : null;
  }

  // Create Post (for Business)
  Future<void> createPost({
    required File imageFile,
    required String description,
    required String salonId,
    required String salonName,
    required String salonLocation,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // 1. Compress Image
    final compressedFile = await _compressImage(imageFile);
    if (compressedFile == null) throw Exception('Image compression failed');

    final int size = await compressedFile.length();
    debugPrint("Compressed Image Size: ${size / 1024} KB"); // Verification log

    final String fileName = '${const Uuid().v4()}.jpg';
    final String path = 'posts/$fileName';

    // 2. Upload to Supabase
    await _supabase.storage
        .from('salon-images')
        .upload(
          path,
          compressedFile,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final String imageUrl = _supabase.storage
        .from('salon-images')
        .getPublicUrl(path);

    // 3. Save to Firestore
    final newPost = PostModel(
      id: '', // Firestore will assign
      salonId: salonId,
      salonName: salonName,
      salonLocation: salonLocation,
      userId: user.uid,
      imageUrl: imageUrl,
      description: description,
      likes: [],
      createdAt: DateTime.now(),
    );

    await _firestore.collection('posts').add(newPost.toMap());
  }

  // Creates post for Web (using bytes)
  Future<void> createPostWeb({
    required Uint8List imageBytes,
    required String description,
    required String salonId,
    required String salonName,
    required String salonLocation,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // On Web, complex compression via dart:io File isn't available easily.
    // Ideally use flutter_image_compress.compressWithList but
    // for now we upload directly or use a simple logic if needed.
    // NOTE: flutter_image_compress supports web via compressWithList

    Uint8List uploadBytes = imageBytes;

    try {
      final compressed = await FlutterImageCompress.compressWithList(
        imageBytes,
        minHeight: 1080,
        minWidth: 1080,
        quality: 85,
      );
      uploadBytes = compressed;
    } catch (e) {
      debugPrint('Web compression failed/skipped: $e');
    }

    final String fileName = '${const Uuid().v4()}.jpg';
    final String path = 'posts/$fileName';

    // 2. Upload to Supabase (binary)
    await _supabase.storage
        .from('salon-images')
        .uploadBinary(
          path,
          uploadBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final String imageUrl = _supabase.storage
        .from('salon-images')
        .getPublicUrl(path);

    // 3. Save to Firestore
    final newPost = PostModel(
      id: '',
      salonId: salonId,
      salonName: salonName,
      salonLocation: salonLocation,
      userId: user.uid,
      imageUrl: imageUrl,
      description: description,
      likes: [],
      createdAt: DateTime.now(),
    );

    await _firestore.collection('posts').add(newPost.toMap());
  }
}
