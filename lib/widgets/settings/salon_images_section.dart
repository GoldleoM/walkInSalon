import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SalonImagesSection extends StatelessWidget {
  final String? logoUrl;
  final String? coverUrl;
  final ValueChanged<Uint8List> onLogoPicked;
  final ValueChanged<Uint8List> onCoverPicked;

  const SalonImagesSection({
    super.key,
    required this.logoUrl,
    required this.coverUrl,
    required this.onLogoPicked,
    required this.onCoverPicked,
  });

  Future<void> _pickImage(ValueChanged<Uint8List> onPicked) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      onPicked(result.files.single.bytes!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: coverUrl != null
                      ? NetworkImage(coverUrl!)
                      : const AssetImage("assets/default_cover.jpg")
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton.small(
                onPressed: () => _pickImage(onCoverPicked),
                backgroundColor: Colors.black54,
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: logoUrl != null
                    ? NetworkImage(logoUrl!)
                    : const AssetImage("assets/default_logo.png")
                        as ImageProvider,
              ),
              FloatingActionButton.small(
                onPressed: () => _pickImage(onLogoPicked),
                backgroundColor: const Color(0xFF023047),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
