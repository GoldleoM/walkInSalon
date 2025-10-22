import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

// Widgets
import 'package:walkinsalonapp/widgets/settings/salon_images_section.dart';
import 'package:walkinsalonapp/widgets/settings/salon_details_form.dart';
import 'package:walkinsalonapp/widgets/settings/logout_button.dart';

// Services
import 'package:walkinsalonapp/services/settings/firestore_settings_service.dart';
import 'package:walkinsalonapp/services/settings/image_upload_settings_service.dart';
import 'package:walkinsalonapp/services/settings/location_settings_service.dart';
import 'dart:typed_data';


class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  final _firestore = FirestoreService();
  final _imageService = ImageUploadService();
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
        logoUrl = business['profileImage'];
        coverUrl = business['coverImage'];
        email.text = userData['email'] ?? user.email ?? '';

        final lat = business['latitude'];
        final lng = business['longitude'];
        if (lat != null && lng != null) {
          selectedLocation = LatLng(lat, lng);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
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
      final uploadedLogo = await _imageService.uploadImage(
        userId: user.uid,
        isLogo: true,
        logoBytes: logoBytes,
      );

      final uploadedCover = await _imageService.uploadImage(
        userId: user.uid,
        isLogo: false,
        coverBytes: coverBytes,
      );

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

      await _firestore.saveUserEmail(user.uid, email.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salon profile updated successfully!')),
      );
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Salon Profile & Settings"),
        backgroundColor: const Color(0xFF023047),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🖼️ Image section (Logo + Cover)
                SalonImagesSection(
                  logoUrl: logoUrl,
                  coverUrl: coverUrl,
                  onLogoPicked: (bytes) => setState(() => logoBytes = bytes),
                  onCoverPicked: (bytes) => setState(() => coverBytes = bytes),
                ),
                const SizedBox(height: 20),

                // 📝 Salon details form
                SalonDetailsForm(
                  salonName: salonName,
                  phone: phone,
                  address: address,
                  email: email,
                  onMapSelect: (loc, addr) {
                    setState(() {
                      selectedLocation = loc;
                      address.text = addr;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 💾 Save button
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: const Icon(Icons.save),
                  label: _isSaving
                      ? const Text("Saving...")
                      : const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF023047),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🚪 Logout button
                const LogoutButton(),
              ],
            ),
          ),

          // Overlay while saving
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
