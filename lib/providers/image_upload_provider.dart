import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkinsalonapp/services/image_upload_service.dart';

// Service Provider
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  // ImageUploadService uses static methods but we treat it as an instance/service 
  // for dependency injection purposes.
  return ImageUploadService();
});
