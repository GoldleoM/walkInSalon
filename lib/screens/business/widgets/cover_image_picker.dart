import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io';

class CoverImagePicker extends StatelessWidget {
  final Uint8List? webCoverImage;
  final File? coverImage;
  final VoidCallback onTap;

  const CoverImagePicker({
    super.key,
    this.webCoverImage,
    this.coverImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    DecorationImage? coverDecoration;

    if (kIsWeb && webCoverImage != null) {
      coverDecoration =
          DecorationImage(image: MemoryImage(webCoverImage!), fit: BoxFit.cover);
    } else if (!kIsWeb && coverImage != null) {
      coverDecoration =
          DecorationImage(image: FileImage(coverImage!), fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: coverDecoration,
          borderRadius: BorderRadius.circular(12),
        ),
        child: coverDecoration == null
            ? const Center(child: Text("Tap to add cover photo"))
            : null,
      ),
    );
  }
}
