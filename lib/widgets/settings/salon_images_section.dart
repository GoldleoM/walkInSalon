import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:walkinsalonapp/core/app_config.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkinsalonapp/providers/image_upload_provider.dart';

class SalonImagesSection extends ConsumerStatefulWidget {
  final String? logoUrl;
  final String? coverUrl;
  final Uint8List? logoBytes;
  final Uint8List? coverBytes;
  final ValueChanged<Uint8List>? onLogoPicked;
  final ValueChanged<Uint8List>? onCoverPicked;

  const SalonImagesSection({
    super.key,
    this.logoUrl,
    this.coverUrl,
    this.logoBytes,
    this.coverBytes,
    this.onLogoPicked,
    this.onCoverPicked,
  });

  @override
  ConsumerState<SalonImagesSection> createState() => _SalonImagesSectionState();
}

class _SalonImagesSectionState extends ConsumerState<SalonImagesSection> {
  Uint8List? _logoBytes;
  Uint8List? _coverBytes;

  @override
  void initState() {
    super.initState();
    _logoBytes = widget.logoBytes;
    _coverBytes = widget.coverBytes;
  }

  @override
  void didUpdateWidget(covariant SalonImagesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep in sync with parent
    if (oldWidget.logoBytes != widget.logoBytes) {
      _logoBytes = widget.logoBytes;
    }
    if (oldWidget.coverBytes != widget.coverBytes) {
      _coverBytes = widget.coverBytes;
    }
  }

  Future<void> _pickAndUpload(String type) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.single.bytes;
    if (bytes == null) return;

    setState(() {
      if (type == 'logo' || type == 'profile') {
        _logoBytes = bytes;
        widget.onLogoPicked?.call(bytes);
      } else {
        _coverBytes = bytes;
        widget.onCoverPicked?.call(bytes);
      }
    });

    // Upload asynchronously — don’t block UI
    try {
      await ref.read(imageUploadServiceProvider).uploadImage(bytes, type);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ======= COVER IMAGE =======
        Stack(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _coverBytes != null
                      ? MemoryImage(_coverBytes!)
                      : (widget.coverUrl != null && widget.coverUrl!.isNotEmpty)
                      ? NetworkImage(widget.coverUrl!)
                      : AssetImage(AppConfig.images.defaultCover)
                            as ImageProvider,
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton.small(
                heroTag: "cover_image_picker_fab",
                backgroundColor: AppColors.primary,
                onPressed: () => _pickAndUpload('cover'),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ======= LOGO (PROFILE) =======
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppConfig.adaptiveSurface(context),
              backgroundImage: _logoBytes != null
                  ? MemoryImage(_logoBytes!)
                  : (widget.logoUrl != null && widget.logoUrl!.isNotEmpty)
                  ? NetworkImage(widget.logoUrl!)
                  : AssetImage(AppConfig.images.defaultProfile)
                        as ImageProvider,
            ),
            FloatingActionButton.small(
              heroTag: "profile_image_picker_fab",
              backgroundColor: AppColors.primary,
              onPressed: () => _pickAndUpload('profile'),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
