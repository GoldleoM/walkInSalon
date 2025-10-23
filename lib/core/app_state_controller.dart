import 'package:flutter/material.dart';
import 'app_image_manager.dart';

class AppStateController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  String? profileUrl;
  String? coverUrl;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<void> loadImages(String uid) async {
    profileUrl = await AppImageManager.getImageUrl('businesses/$uid/profile.jpg');
    coverUrl = await AppImageManager.getImageUrl('businesses/$uid/cover.jpg');
    notifyListeners();
  }

  Future<void> refreshImages(String uid) async {
    await AppImageManager.refreshImage('businesses/$uid/profile.jpg');
    await AppImageManager.refreshImage('businesses/$uid/cover.jpg');
    await loadImages(uid);
  }
}
