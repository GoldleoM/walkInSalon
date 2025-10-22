import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<String?> uploadImage(dynamic imageFile, String type) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final filePath = 'businesses/${user.uid}/$type.jpg';

      if (kIsWeb && imageFile is Uint8List) {
        await _supabase.storage.from('salon-images').uploadBinary(
              filePath,
              imageFile,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
      } else if (imageFile is File) {
        await _supabase.storage.from('salon-images').upload(
              filePath,
              imageFile,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
      }

      return _supabase.storage.from('salon-images').getPublicUrl(filePath);
    } catch (e) {
      rethrow;
    }
  }
}
