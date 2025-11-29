import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img; // for web/dart compression

class ImageUploadService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads image bytes (web) or a File (mobile) after compressing/resizing.
  /// Returns the public URL string (or null on failure).
  static Future<String?> uploadImage(dynamic imageFile, String type) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final filePath = 'businesses/${user.uid}/$type.jpg';

      // For logging/debugging
      void log(String msg) {
        // Replace with your logger if desired
        // ignore: avoid_print
        print('[ImageUploadService] $msg');
      }

      Uint8List? finalBytes;

      if (kIsWeb && imageFile is Uint8List) {
        // Web: use pure Dart 'image' package (reliable on web)
        log('Running web compression via `image` package...');
        final originalBytes = imageFile;
        log('Original size (bytes): ${originalBytes.length}');

        final decoded = img.decodeImage(originalBytes);
        if (decoded == null) {
          log('Failed to decode image bytes on web.');
          throw Exception('Failed to decode image bytes');
        }

        // Resize to max 512 width (maintain aspect ratio)
        final resized = img.copyResize(decoded, width: 512);

        // Re-encode as JPEG with quality 80
        final encoded = img.encodeJpg(resized, quality: 80);
        finalBytes = Uint8List.fromList(encoded);
        log('Compressed size (bytes): ${finalBytes.length}');

        // Upload binary
        await _supabase.storage.from('salon-images').uploadBinary(
          filePath,
          finalBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );
      } else if (imageFile is File) {
        // Mobile: use flutter_image_compress
        log('Running mobile compression via flutter_image_compress...');
        final origSize = await imageFile.length();
        log('Original file size: $origSize bytes');

        final tempDir = await getTemporaryDirectory();
        final targetPath = p.join(
          tempDir.path,
          '${DateTime.now().millisecondsSinceEpoch}_$type.jpg',
        );

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          imageFile.absolute.path,
          targetPath,
          minWidth: 512,
          minHeight: 512,
          quality: 80,
          // You can add rotate/format options here if needed
        );

        if (compressedFile == null) {
          log('compressAndGetFile returned null — uploading original file.');
          // If null, continue with original file
          await _supabase.storage.from('salon-images').upload(
                filePath,
                imageFile,
                fileOptions:
                    const FileOptions(contentType: 'image/jpeg', upsert: true),
              );
        } else {
          final compSize = await compressedFile.length();
          log('Compressed file size: $compSize bytes');

          await _supabase.storage.from('salon-images').upload(
                filePath,
                compressedFile as File,
                fileOptions:
                    const FileOptions(contentType: 'image/jpeg', upsert: true),
              );
        }
      } else if (imageFile is Uint8List) {
        // Non-web but still bytes — attempt compressWithList (best-effort)
        log('Input is Uint8List on non-web — attempting compressWithList...');
        try {
          final bytes = await FlutterImageCompress.compressWithList(
            imageFile,
            minWidth: 512,
            minHeight: 512,
            quality: 80,
          );
          finalBytes = Uint8List.fromList(bytes);
          log('Compressed size (bytes): ${finalBytes.length}');
          await _supabase.storage
              .from('salon-images')
              .uploadBinary(filePath, finalBytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
        } catch (e) {
          log('compressWithList failed: $e — uploading original bytes.');
          await _supabase.storage
              .from('salon-images')
              .uploadBinary(filePath, imageFile, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
        }
      } else {
        throw Exception('Unsupported imageFile type: ${imageFile.runtimeType}');
      }

      // Return public URL
      final publicUrl = _supabase.storage.from('salon-images').getPublicUrl(filePath);
      log('Uploaded -> publicUrl: $publicUrl');
      return publicUrl;
    } catch (e, st) {
      // Helpful debugging info
      // ignore: avoid_print
      print('[ImageUploadService] ERROR: $e\n$st');
      rethrow;
    }
  }
}
