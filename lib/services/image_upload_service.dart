import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageUploadService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String?> uploadImage(dynamic imageFile, String type) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final filePath = 'businesses/${user.uid}/$type.jpg';
    void log(String msg) => print('[ImageUploadService] $msg');

    try {
      if (kIsWeb && imageFile is Uint8List) {
        await _supabase.storage
            .from('salon-images')
            .uploadBinary(
              filePath,
              imageFile,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
      } else if (imageFile is File) {
        await _supabase.storage
            .from('salon-images')
            .upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
      } else if (imageFile is Uint8List) {
        await _supabase.storage
            .from('salon-images')
            .uploadBinary(
              filePath,
              imageFile,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
      } else {
        throw Exception('Unsupported image type: ${imageFile.runtimeType}');
      }

      final url = _supabase.storage.from('salon-images').getPublicUrl(filePath);

      // bump version for cache busting
      await _firestore.collection('businesses').doc(user.uid).update({
        '${type}Image': url,
        'imageVersion': FieldValue.increment(1),
      });

      // clear cached old file
      try {
        await DefaultCacheManager().removeFile(url);
      } catch (_) {}

      log('✅ Uploaded $type → $url');
      return url;
    } catch (e, st) {
      log('❌ Upload failed: $e\n$st');
      rethrow;
    }
  }
}
