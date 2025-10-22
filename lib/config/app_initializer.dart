import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'supabase_config.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
}
