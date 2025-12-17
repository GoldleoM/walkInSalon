import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:walkinsalonapp/auth/login/auth_wrapper.dart';

// 🧱 Core + Config
import 'core/app_config.dart';
import 'config/firebase_options.dart';
import 'config/supabase_config.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  // 🪣 Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Optional warm-up delay (for splash smoothness)
  await Future.delayed(const Duration(milliseconds: 200));

  runApp(
    const ProviderScope(
      child: WalkInSalonApp(),
    ),
  );
}

class WalkInSalonApp extends StatelessWidget {
  const WalkInSalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // 🎨 Unified AppConfig theming
      theme: AppConfig.themeLight,
      themeMode: ThemeMode.system,

      // 📱 Responsive Framework
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: widget!,
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1200, name: DESKTOP),
          Breakpoint(start: 1201, end: double.infinity, name: '4K'),
        ],
      ),

      // 🧭 Initial route (splash → auth)
      home: const AuthWrapper(),
    );
  }
}
