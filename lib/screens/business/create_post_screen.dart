import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _descriptionController = TextEditingController();
  final _postService = PostService();
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // For Web
  bool _isLoading = false;

  Future<void> _pickImage() async {
    // For mobile we might want image_picker, but file_picker works broadly
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Needed for Web
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          _selectedImageBytes = result.files.single.bytes;
        } else if (result.files.single.path != null) {
          _selectedImage = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _submitPost() async {
    if (_selectedImage == null && _selectedImageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user found');

      // Fetch salon details to embed in post
      final userDoc = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(user.uid)
          .get();

      final salonName = userDoc.data()?['salonName'] ?? 'Unknown Salon';
      final address = userDoc.data()?['address'] ?? 'Unknown Location';

      if (kIsWeb && _selectedImageBytes != null) {
        await _postService.createPostWeb(
          imageBytes: _selectedImageBytes!,
          description: _descriptionController.text.trim(),
          salonId: user.uid,
          salonName: salonName,
          salonLocation: address,
        );
      } else if (_selectedImage != null) {
        await _postService.createPost(
          imageFile: _selectedImage!,
          description: _descriptionController.text.trim(),
          salonId: user.uid,
          salonName: salonName,
          salonLocation: address,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.adaptiveBackground(context),
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: AppConfig.adaptiveSurface(context),
        elevation: 0,
        foregroundColor: AppConfig.adaptiveTextColor(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: (_selectedImage != null || _selectedImageBytes != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          child: kIsWeb
                              ? Image.memory(
                                  _selectedImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: AppColors.secondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to select image',
                              style: TextStyle(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description Input
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                filled: true,
                fillColor: AppConfig.adaptiveSurface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
