import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io';

class ProfileImagePicker extends StatelessWidget {
  final Uint8List? webProfileImage;
  final File? profileImage;
  final VoidCallback onTap;

  const ProfileImagePicker({
    super.key,
    this.webProfileImage,
    this.profileImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage: kIsWeb
            ? (webProfileImage != null ? MemoryImage(webProfileImage!) : null)
            : (profileImage != null ? FileImage(profileImage!) : null),
        child: (profileImage == null && webProfileImage == null)
            ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
            : null,
      ),
    );
  }
}
