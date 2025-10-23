import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core + Widgets
import 'package:walkinsalonapp/core/app_config.dart';
import 'package:walkinsalonapp/widgets/settings/salon_images_section.dart';
import 'package:walkinsalonapp/widgets/settings/salon_details_form.dart';
import 'package:walkinsalonapp/widgets/settings/logout_button.dart';

// Services
import 'package:walkinsalonapp/services/settings/firestore_settings_service.dart';
import 'package:walkinsalonapp/services/settings/location_settings_service.dart';
import 'package:walkinsalonapp/services/image_upload_service.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final _firestore = FirestoreService();
  final _locationService = LocationService();

  bool _isSaving = false;
  bool _isLoading = true;

  final salonName = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final email = TextEditingController();

  LatLng? selectedLocation;
  String? logoUrl;
  String? coverUrl;

  Uint8List? logoBytes;
  Uint8List? coverBytes;

  @override
  void initState() {
    super.initState();
    _loadSalonData();
  }

  Future<void> _loadSalonData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final business = await _firestore.loadBusinessData(user.uid);
      final userData = await _firestore.loadUserData(user.uid);

      if (!mounted) return;
      setState(() {
        salonName.text = business['salonName'] ?? '';
        phone.text = business['phone'] ?? '';
        address.text = business['address'] ?? '';
        email.text = userData['email'] ?? user.email ?? '';

        // ✅ Add cache-busting for image URLs
        final version = (business['imageVersion'] ?? '').toString();
        final logo = business['profileImage'] ?? '';
        final cover = business['coverImage'] ?? '';
        logoUrl = logo.isNotEmpty ? '$logo?v=$version' : null;
        coverUrl = cover.isNotEmpty ? '$cover?v=$version' : null;

        final lat = business['latitude'];
        final lng = business['longitude'];
        if (lat != null && lng != null) {
          selectedLocation = LatLng(lat, lng);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // Upload new images if selected
      String? uploadedLogo;
      String? uploadedCover;

      if (logoBytes != null) {
        uploadedLogo =
            await ImageUploadService.uploadImage(logoBytes, 'profile');
      }

      if (coverBytes != null) {
        uploadedCover =
            await ImageUploadService.uploadImage(coverBytes, 'cover');
      }

      // Save business details to Firestore
      await _firestore.saveBusinessData(
        userId: user.uid,
        salonName: salonName.text.trim(),
        phone: phone.text.trim(),
        address: address.text.trim(),
        latitude: selectedLocation?.latitude,
        longitude: selectedLocation?.longitude,
        logoUrl: uploadedLogo ?? logoUrl,
        coverUrl: uploadedCover ?? coverUrl,
      );

      // ✅ Only update email field in Firestore (not Firebase Auth)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'email': email.text.trim()});

      // ✅ Update image version for cache-busting
      final newVersion = DateTime.now().millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(user.uid)
          .update({'imageVersion': newVersion});

      if (!mounted) return;
      setState(() {
        if (uploadedLogo != null) {
          logoUrl = '$uploadedLogo?v=$newVersion';
          logoBytes = null;
        }
        if (uploadedCover != null) {
          coverUrl = '$uploadedCover?v=$newVersion';
          coverBytes = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Salon profile updated successfully!')),
      );

      // 🔄 Refresh data from Firestore to ensure new URLs are loaded
      await _loadSalonData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text("Salon Profile & Settings"),
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.primary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              children: [
                // 🖼️ Salon Images
                SalonImagesSection(
                  logoUrl: logoUrl,
                  coverUrl: coverUrl,
                  logoBytes: logoBytes,
                  coverBytes: coverBytes,
                  onLogoPicked: (bytes) {
                    if (!mounted) return;
                    setState(() => logoBytes = bytes);
                  },
                  onCoverPicked: (bytes) {
                    if (!mounted) return;
                    setState(() => coverBytes = bytes);
                  },
                ),
                const SizedBox(height: 20),

                // 🧾 Details
                SalonDetailsForm(
                  salonName: salonName,
                  phone: phone,
                  address: address,
                  email: email,
                  onMapSelect: (loc, addr) {
                    if (!mounted) return;
                    setState(() {
                      selectedLocation = loc;
                      address.text = addr;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 💾 Save Button
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: const Icon(Icons.save),
                  label: _isSaving
                      ? const Text("Saving...")
                      : const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.darkSecondary : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const LogoutButton(),
              ],
            ),
          ),

          // ⏳ Overlay while saving
          if (_isSaving)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
