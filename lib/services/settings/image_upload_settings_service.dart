import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadImage({
    required String userId,
    required bool isLogo,
    Uint8List? logoBytes,
    Uint8List? coverBytes,
  }) async {
    final bytes = isLogo ? logoBytes : coverBytes;
    if (bytes == null) return null;

    final filePath = 'businesses/$userId/${isLogo ? "profile" : "cover"}.jpg';

    await _supabase.storage
        .from('salon-images')
        .uploadBinary(filePath, bytes, fileOptions: const FileOptions(upsert: true));

    return _supabase.storage.from('salon-images').getPublicUrl(filePath);
  }
}
