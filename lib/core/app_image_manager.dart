import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageManager {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final _cache = DefaultCacheManager();

  /// Fetches from cache or Supabase.
  static Future<String?> getImageUrl(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUrl = prefs.getString(path);

    if (cachedUrl != null) return cachedUrl;

    final url = _supabase.storage.from('salon-images').getPublicUrl(path);
    await prefs.setString(path, url);
    return url;
  }

  /// Refresh only when user updates from settings
  static Future<void> refreshImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final newUrl = _supabase.storage.from('salon-images').getPublicUrl(path);
    await prefs.setString(path, newUrl);
  }

  /// Optional: clear all cached URLs
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _cache.emptyCache();
  }
}
